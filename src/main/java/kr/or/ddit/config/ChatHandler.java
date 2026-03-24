package kr.or.ddit.config;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import kr.or.ddit.mapper.AlarmMapper;
import kr.or.ddit.service.ChatService;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.ChatLogVO;
import kr.or.ddit.vo.ChatRoomVO;
import kr.or.ddit.vo.ChatUserVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class ChatHandler extends TextWebSocketHandler {

    @Autowired
    @Lazy
    private ChatService chatService;
    
    @Autowired
    private AlarmMapper alarmMapper;
    
    @Autowired
    private AlarmController alarmController;

    private final ObjectMapper objectMapper = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    private static List<WebSocketSession> sessionList = new CopyOnWriteArrayList<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessionList.add(session);
        log.info("✅ 새 연결 완료. 세션 ID: {}, 현재 접속자: {}", session.getId(), sessionList.size());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            String payload = message.getPayload();
            log.info("📢 [수신 데이터]: {}", payload); 
            
            com.fasterxml.jackson.databind.JsonNode rootNode = objectMapper.readTree(payload);

            // 🚀 [1. ENTER / LEAVE 처리 로직]
            if (rootNode.has("type")) {
                String type = rootNode.get("type").asText();
                
                if ("ENTER".equals(type) || "LEAVE".equals(type)) {
                    // 숫자가 문자열로 넘어올 경우를 대비해asText() 후 parseInt 사용
                    int chatRmNo = rootNode.has("chatRmNo") ? Integer.parseInt(rootNode.get("chatRmNo").asText()) : 0;
                    int empId = rootNode.has("empId") ? Integer.parseInt(rootNode.get("empId").asText()) : 0;
                    
                    log.info("📥 [상태 통지 수신] 타입: {}, 사번: {}, 방번호: {}", type, empId, chatRmNo);

                    for (WebSocketSession s : sessionList) {
                        if (s != null && s.isOpen()) {
                            Object loginIdObj = s.getAttributes().get("loginId");
                            // 비교 시에는 양쪽 다 String으로 변환하여 타입 불일치 완전 방지
                            if (loginIdObj != null && String.valueOf(loginIdObj).equals(String.valueOf(empId))) {
                                if ("ENTER".equals(type)) {
                                    s.getAttributes().put("chatRmNo", String.valueOf(chatRmNo)); // String으로 저장
                                    log.info("📌 [세션 활성화 완료] 사번 {}님이 {}번 방에 입장함", empId, chatRmNo);
                                } else {
                                    s.getAttributes().remove("chatRmNo");
                                    log.info("📌 [세션 비활성화 완료] 사번 {}님이 채팅 종료함", empId);
                                }
                            }
                        }
                    }
                    
                    if ("ENTER".equals(type)) {
                        try {
                            Map<String, Object> readParam = new HashMap<>();
                            readParam.put("empId", empId);
                            readParam.put("chatRmNo", String.valueOf(chatRmNo));
                            alarmMapper.readChatAlarm(readParam); 
                            
                            Map<String, Object> refreshMap = new HashMap<>();
                            refreshMap.put("type", "REFRESH_ALARM_COUNT");
                            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(refreshMap)));
                        } catch (Exception e) { log.error("⚠️ 알람 읽음처리 오류: {}", e.getMessage()); }
                    }
                    return; 
                }
            }

            // 🚀 [2. 메시지 발송 및 알림 필터링 로직]
            ChatLogVO chatLog = rootNode.has("data") ? 
                    objectMapper.treeToValue(rootNode.get("data"), ChatLogVO.class) : 
                    objectMapper.readValue(payload, ChatLogVO.class);
            
            if (chatLog != null && chatLog.getChatRmNo() > 0) {
                int chatRmNo = chatLog.getChatRmNo();
                int myEmpId = chatLog.getEmpId();

                List<ChatUserVO> userList = chatService.selectChatUserList(chatRmNo);
                List<Integer> rcvrNoList = new ArrayList<>();
                
                log.info("🔎 [알림 필터링 시작] 방번호: {}, 송신자: {}", chatRmNo, myEmpId);

                for (ChatUserVO user : userList) {
                    int targetEmpId = user.getEmpId();
                    if (targetEmpId == myEmpId) continue;

                    boolean isUserInCurrentRoom = false;
                    for (WebSocketSession s : sessionList) {
                        if (s != null && s.isOpen()) {
                            Object sEmpIdObj = s.getAttributes().get("loginId");
                            Object sRoomNoObj = s.getAttributes().get("chatRmNo");
                            
                            if (sEmpIdObj != null) {
                                String sEmpId = String.valueOf(sEmpIdObj);
                                String sRoomNo = (sRoomNoObj != null) ? String.valueOf(sRoomNoObj) : "NONE";

                                // 🌟 핵심: 비교 시 로그를 찍어 실제 값 확인
                                if (sEmpId.equals(String.valueOf(targetEmpId)) && sRoomNo.equals(String.valueOf(chatRmNo))) {
                                    isUserInCurrentRoom = true;
                                    log.info("🚫 [알림 제외됨] 사번 {}님은 현재 {}번 방을 보고 있어 알림을 보내지 않음", targetEmpId, chatRmNo);
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (!isUserInCurrentRoom) {
                        log.info("🔔 [알림 대상 확정] 사번 {}님은 {}번 방에 없음", targetEmpId, chatRmNo);
                        rcvrNoList.add(targetEmpId);
                    }
                }

             // 🚀 [메시지 알람 생성 및 발송 로직]
                if (!rcvrNoList.isEmpty()) {
                    AlarmVO alarmVO = new AlarmVO();
                    alarmVO.setAlmMsg("새로운 채팅 메시지");
                    
                    // 1. 메시지 내용 요약 (기존 로직 유지)
                    String content = chatLog.getChatCn();
                    if (content != null && content.length() > 15) {
                        content = content.substring(0, 15) + "...";
                    }
                    alarmVO.setAlmDtl(chatLog.getEmpNm() + " : " + content);
                    
                    // 2. 수신자 목록 설정
                    alarmVO.setAlmRcvrNos(rcvrNoList);
                    
                    // 3. [수정] 아이콘 설정 (SweetAlert2 호환을 위해 "info"로 통일)
                    // 기존에 아래쪽에서 "chat"으로 다시 세팅하던 중복 코드를 제거했습니다.
                    alarmVO.setAlmIcon("info"); 
                    
                    // 4. [핵심] 읽음 처리용 동적 URL 생성
                    // DB의 ALM_URL 컬럼에 방 번호가 포함되어야 나중에 클릭/입장 시 지워집니다.
                    String dynamicUrl = "/chat/main?chatRmNo=" + chatRmNo; 
                    
                    log.info("🔔 [알림 생성 완료] 대상: {}, URL: {}", rcvrNoList, dynamicUrl);

                    // 5. 알람 발송 (세 번째 인자에 dynamicUrl 전달)
                    this.alarmController.sendAlarm(myEmpId, alarmVO, dynamicUrl, "채팅");
                }
                
                // 실시간 메시지 브로드캐스팅
                String resultJson = objectMapper.writeValueAsString(chatLog);
                TextMessage broadcastMsg = new TextMessage(resultJson);
                for (WebSocketSession s : sessionList) {
                    if (s != null && s.isOpen()) {
                        try { s.sendMessage(broadcastMsg); } catch (Exception e) { sessionList.remove(s); }
                    }
                }
            }
        } catch (Exception e) { 
            log.error("🔥 메시지 처리 오류: {}", e.getMessage()); 
        }
    }
    
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessionList.remove(session);
        log.info("🚫 연결 종료. 현재 접속자 수: {}", sessionList.size());
    }
    
    public void sendToRoom(int chatRmNo, ChatLogVO chatLog) {
        try {
            String jsonMsg = objectMapper.writeValueAsString(chatLog);
            TextMessage textMessage = new TextMessage(jsonMsg);

            for (WebSocketSession session : sessionList) {
                if (session != null && session.isOpen()) {
                    session.sendMessage(textMessage);
                }
            }
            log.info("📢 [실시간 전송] 방번호: {}, 내용: {}", chatRmNo, chatLog.getChatCn());
        } catch (Exception e) {
            log.error("❌ 실시간 메시지 전송 중 오류: {}", e.getMessage());
        }
    }
}