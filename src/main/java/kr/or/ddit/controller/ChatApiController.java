package kr.or.ddit.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.config.ChatHandler;
import kr.or.ddit.mapper.AlarmMapper;
import kr.or.ddit.service.ChatService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmReceiveVO;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.ChatLogVO;
import kr.or.ddit.vo.ChatRoomVO;
import kr.or.ddit.vo.ChatUserVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.FileTbVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/chat-api")
public class ChatApiController {

    @Autowired
    private ChatService chatService;
    
    //알람 발송
    @Autowired
    private AlarmMapper alarmMapper;
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    @Autowired
    private ChatHandler chatHandler;
    
    @Autowired
    private kr.or.ddit.util.UploadController uploadController;

    
    /**
     * 채팅 파일 업로드 API
     * (JS에서 FormData로 multipartFiles, chatRmNo를 보낼 때 대응)
     */
    @PostMapping("/upload")
    public ResponseEntity<?> uploadChatFile(
            @RequestParam("multipartFiles") MultipartFile[] files,
            @RequestParam("chatRmNo") int chatRmNo,
            Authentication auth) {
        
        // 1. 로그인 체크 및 사용자 정보 추출 (기존 유지)
        if (auth == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인이 필요합니다.");
        }
        
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId(); 

        log.info("📢 파일 업로드 요청 - 방번호: {}, 사번: {}, 파일수: {}", chatRmNo, empId, files.length);

        try {
            // 2. 서비스 호출 (기존 로직 유지)
            long fileGroupNo = chatService.uploadChatFiles(files, empId);

            if (fileGroupNo > 0) {
                // ✅ [수정] 단순 숫자 대신 Map을 활용해 파일 정보(ID + 이름)를 함께 반환
                Map<String, Object> result = new HashMap<>();
                result.put("fileId", fileGroupNo);
                
                // 전송된 파일 중 첫 번째 파일의 원본 이름을 담아줍니다.
                if (files != null && files.length > 0) {
                    result.put("fileName", files[0].getOriginalFilename());
                }

                log.info("✅ 파일 업로드 성공 - 그룹번호: {}, 파일명: {}", fileGroupNo, result.get("fileName"));
                return ResponseEntity.ok(result); 
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("파일이 업로드되지 않았습니다.");
            }

        } catch (Exception e) {
            log.error("❌ 파일 업로드 중 서버 에러: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("fail: " + e.getMessage());
        }
    }
    
    /**
     * 초대 가능한 사원 목록 조회
     */
    @GetMapping("/inviteList")
    public List<EmployeeVO> getInviteList(@RequestParam("chatRmNo") int chatRmNo) {
        log.info("초대 가능 리스트 조회 - 방번호: {}", chatRmNo);
        
        // [꿀팁] 나중에 SQL 쿼리에서 '이 방에 이미 참여 중인 사람'을 제외하고 
        // 가져오는 메서드를 만드시면 더 완벽합니다. (지금은 전체 리스트)
        return chatService.selectAllEmployeeList(); 
    }

    /**
     * 사원 초대 실행
     */
    @PostMapping("/invite")
    public ResponseEntity<String> invite(@RequestBody Map<String, Object> params, Authentication authentication) {
        try {
            int chatRmNo = Integer.parseInt(params.get("chatRmNo").toString());
            
            // 1. 초대할 사원 리스트 변환 (기존 유지)
            List<?> rawList = (List<?>) params.get("inviteIdList");
            List<Integer> inviteIdList = rawList.stream()
                .map(obj -> Integer.parseInt(obj.toString()))
                .collect(Collectors.toList());
            
            // 2. 현재 로그인한 사람 정보 가져오기 (기존 유지)
            int myEmpId = 0;
            String myEmpNm = "사용자";
            String myEmpJbgd = "";
            if (authentication != null) {
                CustomUser userDetails = (CustomUser) authentication.getPrincipal();
                myEmpId = userDetails.getEmpVO().getEmpId();
                myEmpNm = userDetails.getEmpVO().getEmpNm();
                myEmpJbgd = userDetails.getEmpVO().getEmpJbgd();
            }

            log.info("사원 초대 실행 - 방번호: {}, 초대인원: {}명", chatRmNo, inviteIdList.size());
            
            // 3. 실제 서비스 호출 (채팅 참여자 추가)
            chatService.addChatUsers(chatRmNo, inviteIdList);

            // ============================================================
            // 🌟 [시스템 메시지 로직] DB 저장 및 실시간 소켓 전송
            // ============================================================
            if (!inviteIdList.isEmpty()) {
                String invitedNames = chatService.getEmpName(inviteIdList);
                ChatLogVO inviteLog = new ChatLogVO();
                inviteLog.setChatRmNo(chatRmNo);
                inviteLog.setEmpId(myEmpId); 
                String systemMessage = invitedNames + "님이 채팅방에 참여하였습니다.";
                inviteLog.setChatCn(systemMessage);
                inviteLog.setChatDt(new java.util.Date());
                
                chatService.insertChatLog(inviteLog);
                chatHandler.sendToRoom(chatRmNo, inviteLog);
            }

            // ============================================================
            // 🌟 [알람 로직] AlarmMapper를 이용한 직접 등록 (VO 필드 반영)
            // ============================================================
            if (!inviteIdList.isEmpty()) {
                // 1. 알람 마스터 정보 생성 (AlarmVO)
                AlarmVO alarmVO = new AlarmVO();
                alarmVO.setEmpId(myEmpId);       // 보낸사람 (AlarmVO 필드: empId)
                alarmVO.setAlmMsg("채팅방 초대 알림");
                alarmVO.setAlmDtl(
                    "<span class=\"fw-bold\">" + myEmpNm + " " + myEmpJbgd +
                    "</span>님이 당신을 <span class=\"fw-bold text-primary\">채팅방</span>에 초대했습니다.");
                alarmVO.setAlmType("채팅");
                alarmVO.setAlmIcon("info");

                // 🚩 핵심: 읽음 처리 쿼리에서 LIKE '%#{chatRmNo}%' 로 찾을 수 있도록 URL 구성
                // AlarmVO의 almUrl 필드 사용
                String chatRoomUrl = "/chat/main?chatRmNo=" + chatRmNo;
                alarmVO.setAlmUrl(chatRoomUrl);

                // [DB 저장] 알람 마스터 등록
                int result = alarmMapper.insertAlarm(alarmVO); 

                if (result > 0) {
                    // 2. 수신자별 등록 (AlarmReceiveVO)
                    // AlarmMapper의 insertAlarmReceive를 사용하여 초대된 모든 인원 등록
                    for (int rcvrEmpId : inviteIdList) {
                        AlarmReceiveVO receiveVO = new AlarmReceiveVO();
                        receiveVO.setAlmId(alarmVO.getAlmId()); // 생성된 알람 PK (almId)
                        receiveVO.setEmpId(rcvrEmpId);          // 수신자 ID (AlarmReceiveVO 필드: empId)
                        receiveVO.setAlmYn("N");                // 초기 읽음 여부
                        
                        alarmMapper.insertAlarmReceive(receiveVO);
                    }
                    log.info("✅ [알람 DB 등록 완료] 알람ID: {}, 초대인원: {}명", alarmVO.getAlmId(), inviteIdList.size());
                }
            }
            // ============================================================
            
            return ResponseEntity.ok("success");
        } catch (Exception e) {
            log.error("초대 중 오류 발생: {}", e.getMessage());
            return ResponseEntity.internalServerError().body("fail: " + e.getMessage());
        }
    }
    /**
     * 메신저 전용: 1:1 채팅방 번호 가져오기 또는 생성
     */
    @ResponseBody
    @PostMapping("/getOrCreateRoom")
    public ResponseEntity<?> getOrCreateRoom(@RequestBody Map<String, Object> params, Authentication auth) {
        if (auth == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인이 필요합니다.");

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int myEmpId = customUser.getEmpVO().getEmpId();
        String myEmpNm = customUser.getEmpVO().getEmpNm();
        
        int targetId = Integer.parseInt(params.get("targetId").toString());
        String targetNm = params.get("targetNm").toString();

        // 🌟 [수정] 원본 DB 타이틀은 "이름" 형태로 온전히 저장합니다.
        // 그래야 양쪽(이름) 화면에서 XML 쿼리를 탈 때 서로의 이름이 아름답게 교차 치환됩니다!
        String chatRmTtl = myEmpNm + ", " + targetNm; 

        // 1. 기존 채팅방 존재 여부 확인
        ChatRoomVO chatRoomVO = new ChatRoomVO();
        chatRoomVO.setChatRmTtl(chatRmTtl);
        chatRoomVO.setEmpId(myEmpId);
        
        ChatRoomVO existingRoom = chatService.getChatRoomByTitle(chatRmTtl, myEmpId);

        if (existingRoom != null) {
            // ============================================================
            // 🌟 [기존 유지] XML 매퍼의 #{empId} 키와 정확히 맞춤
            // ============================================================
            try {
                if (this.alarmMapper != null) {
                    Map<String, Object> updateMap = new java.util.HashMap<>();
                    
                    updateMap.put("empId", myEmpId); 
                    updateMap.put("chatRmNo", existingRoom.getChatRmNo());
                    
                    int readResult = this.alarmMapper.readChatAlarm(updateMap);
                    if (readResult > 0) {
                        log.info("✅ [API] 기존 채팅방({}) 입장 - 알람 {}건 읽음 처리 완료", existingRoom.getChatRmNo(), readResult);
                    }
                }
            } catch (Exception e) {
                log.error("⚠️ [API] 알람 업데이트 중 오류: {}", e.getMessage());
            }
            // ============================================================
            
            return ResponseEntity.ok(existingRoom); 
        }

        // 2. 존재하지 않는 경우 새로 생성
        chatRoomVO.setChatRmType("DIRECT"); 
        List<Integer> uniqueUsers = new ArrayList<>();
        uniqueUsers.add(targetId);

        chatService.createChatRoomWithUsers(chatRoomVO, uniqueUsers);
        
        // ============================================================
        // 🌟 [기존 유지] 새 채팅방 생성 시 알람 등록
        // ============================================================
        try {
            if (this.alarmMapper != null) {
                AlarmVO alarmVO = new AlarmVO();
                alarmVO.setEmpId(myEmpId); 
                alarmVO.setAlmMsg("1:1 채팅 초대");
                alarmVO.setAlmDtl("<span class='fw-bold'>" + myEmpNm + "</span>님이 1:1 채팅을 시작했습니다.");
                alarmVO.setAlmType("채팅");
                alarmVO.setAlmIcon("chat");
                
                String chatRoomUrl = "/chat/main?chatRmNo=" + chatRoomVO.getChatRmNo();
                alarmVO.setAlmUrl(chatRoomUrl);

                int result = alarmMapper.insertAlarm(alarmVO);
                
                if (result > 0) {
                    for (int rcvrEmpId : uniqueUsers) {
                        AlarmReceiveVO receiveVO = new AlarmReceiveVO();
                        receiveVO.setAlmId(alarmVO.getAlmId()); 
                        receiveVO.setEmpId(rcvrEmpId);          
                        receiveVO.setAlmYn("N");
                        
                        alarmMapper.insertAlarmReceive(receiveVO);
                    }
                    log.info("✅ [API] 새 채팅방 알람 등록 완료 (알람ID: {})", alarmVO.getAlmId());
                }
            }
        } catch (Exception e) {
            log.error("⚠️ [API] 새 채팅방 알람 등록 실패: {}", e.getMessage());
        }

        return ResponseEntity.ok(chatRoomVO); 
    }
    

    @ResponseBody
    @PostMapping("/getOrCreateDirect")
    public ResponseEntity<?> getOrCreateDirect(@RequestParam Map<String, Object> params, Authentication auth) {
        if (auth == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int myEmpId = customUser.getEmpVO().getEmpId();
        String myEmpNm = customUser.getEmpVO().getEmpNm();
        
        int targetId = Integer.parseInt(params.get("targetId").toString());
        String targetNm = params.get("targetNm").toString();
        
        // JS에서 보낸 타입 가져오기
        String chatRmType = params.getOrDefault("chatRmType", "GROUP").toString();
        String typeUpper = chatRmType.toUpperCase().trim();

        // 🌟 [수정 구간: DB 무결성을 위해 이름 결합 유지]
        // 1:1이든 그룹이든 DB 원본에는 "내이름, 상대방이름"으로 저장합니다.
        // 이렇게 해야 양쪽 접속자가 ChatMapper.xml에서 자기 이름을 지우고 상대방 이름을 띄우게 됩니다!
        String chatRmTtl = myEmpNm + ", " + targetNm; 

        ChatRoomVO existingRoom = null;
        try {
            existingRoom = chatService.getChatRoomByTitle(chatRmTtl, myEmpId);
        } catch (Exception e) { 
            log.error("⚠️ 중복된 채팅방 발견: {} / 에러 내용: {}", chatRmTtl, e.getMessage());
            existingRoom = null; 
        }

        if (existingRoom != null) {
            // ============================================================
            // 🌟 [기존 유지] XML 매퍼의 #{empId} 키와 일치하도록 수정
            // ============================================================
            try {
                if (this.alarmMapper != null) {
                    Map<String, Object> updateMap = new java.util.HashMap<>();
                    
                    updateMap.put("empId", myEmpId);          
                    updateMap.put("chatRmNo", existingRoom.getChatRmNo()); 
                    
                    int readResult = this.alarmMapper.readChatAlarm(updateMap); 
                    if (readResult > 0) {
                        log.info("✅ [API] getOrCreateDirect - 방({}) 알람 {}건 읽음 처리 완료", existingRoom.getChatRmNo(), readResult);
                    }
                }
            } catch (Exception alarmEx) {
                log.error("⚠️ [API] 알람 상태 업데이트 중 오류 발생: {}", alarmEx.getMessage());
            }
            // ============================================================

            return ResponseEntity.ok(existingRoom);
        }

        // 2. 없으면 새로 생성
        ChatRoomVO chatRoomVO = new ChatRoomVO();
        chatRoomVO.setChatRmTtl(chatRmTtl);
        chatRoomVO.setEmpId(myEmpId);
        chatRoomVO.setChatRmType(chatRmType); 
        chatRoomVO.setTargetId(targetId);

        List<Integer> uniqueUsers = new ArrayList<>();
        uniqueUsers.add(targetId);
        chatService.createChatRoomWithUsers(chatRoomVO, uniqueUsers);
        
        // ============================================================
        // 🌟 [기존 유지] 새 방 생성 시 알람 등록
        // ============================================================
        try {
            if (this.alarmMapper != null) {
                AlarmVO alarmVO = new AlarmVO();
                alarmVO.setEmpId(myEmpId); 
                alarmVO.setAlmMsg("채팅 초대 알림");
                alarmVO.setAlmDtl("<span class='fw-bold'>" + myEmpNm + "</span>님이 새로운 채팅을 시작했습니다.");
                alarmVO.setAlmType("채팅");
                alarmVO.setAlmIcon("info");

                String chatRoomUrl = "/chat/main?chatRmNo=" + chatRoomVO.getChatRmNo();
                alarmVO.setAlmUrl(chatRoomUrl);

                int result = alarmMapper.insertAlarm(alarmVO);
                
                if (result > 0) {
                    for (int rcvrEmpId : uniqueUsers) {
                        AlarmReceiveVO receiveVO = new AlarmReceiveVO();
                        receiveVO.setAlmId(alarmVO.getAlmId()); 
                        receiveVO.setEmpId(rcvrEmpId);          
                        receiveVO.setAlmYn("N");
                        
                        alarmMapper.insertAlarmReceive(receiveVO);
                    }
                    log.info("✅ [API] getOrCreateDirect - 초대 알람 등록 완료 (알람ID: {})", alarmVO.getAlmId());
                }
            }
        } catch (Exception e) {
            log.error("⚠️ [API] 새 채팅방 알람 등록 실패: {}", e.getMessage());
        }

        return ResponseEntity.ok(chatRoomVO);
    }
    /**
     * 특정 채팅방의 메시지 내역 가져오기 (AJAX용)
     */
    @Transactional
    @GetMapping("/getMessages")
    public ResponseEntity<?> getMessages(@RequestParam("chatRmNo") int chatRmNo, Authentication auth) {
    	log.info("채팅 메시지 로드 요청 - 방번호: {}", chatRmNo);
        
        if (auth == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인이 필요합니다.");
        }
        
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int loginEmpId = customUser.getEmpVO().getEmpId();

        try {
            if (this.alarmMapper != null) {
                Map<String, Object> updateMap = new java.util.HashMap<>();
                updateMap.put("empId", loginEmpId);    
                updateMap.put("chatRmNo", chatRmNo);   
                // 🌟 추가: 매퍼 XML의 <if test="updateStts == 'readChatAlarm'"> 조건을 타기 위해 명시
                updateMap.put("updateStts", "readChatAlarm"); 
                
                int result = this.alarmMapper.readChatAlarm(updateMap); 
                
                if (result > 0) {
                    log.info("✅ [API] 채팅방({}) 입장 - 관련 알람 {}건 DB 읽음 처리 완료", chatRmNo, result);
                }
            }
        } catch (Exception e) {
            log.error("⚠️ [API] 알람 상태 업데이트 중 오류 발생: {}", e.getMessage());
        }
        // ============================================================

        // 2. 메시지 조회를 위한 파라미터 설정
        Map<String, Object> paramMap = new java.util.HashMap<>();
        paramMap.put("chatRmNo", chatRmNo);
        paramMap.put("loginEmpId", loginEmpId);
        
        // 3. 서비스 호출
        List<ChatLogVO> logList = chatService.selectChatLogList(paramMap);
        
        return ResponseEntity.ok(logList);
    }
    
    @ResponseBody
    @PostMapping("/insertLog")
    public ResponseEntity<?> insertLog(@RequestBody ChatLogVO chatLogVO, Authentication auth) {
        if (auth != null) {
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            
            // 1. 현재 로그인한 사용자 정보 세팅 (기존 유지)
            chatLogVO.setEmpId(customUser.getEmpVO().getEmpId());
            chatLogVO.setEmpNm(customUser.getEmpVO().getEmpNm());
            
            // 🌟 프로필 이미지 정보 세팅
            chatLogVO.setEmpProfile(customUser.getEmpVO().getEmpProfile()); 
            
            // 2. 현재 시간 세팅
            chatLogVO.setChatDt(new java.util.Date()); 
            
            // 🌟 [추가 확인] 클라이언트가 보낸 chatType이 잘 들어왔는지 확인 (기본값 TEXT)
            if (chatLogVO.getChatType() == null || chatLogVO.getChatType().isEmpty()) {
                chatLogVO.setChatType("TEXT");
            }
        }
        
        // 3. DB 저장 (Mapper에서 이제 CHAT_TYPE 컬럼에 이 값이 들어갑니다)
        int result = chatService.insertChatLog(chatLogVO);
        
        if(result > 0) {
            // ============================================================
            // 🌟 [추가 로직] 실시간 전송 전 파일 정보 채우기
            // ============================================================
            if (chatLogVO.getFileId() != null && chatLogVO.getFileId() > 0 && (chatLogVO.getFileName() == null || chatLogVO.getFileName().isEmpty())) {
                try {
                    String fileName = chatService.getFileNameByFileId(chatLogVO.getFileId());
                    chatLogVO.setFileName(fileName); 
                    log.info("📂 실시간 메시지에 파일명 매핑 완료: {}", fileName);
                } catch (Exception e) {
                    log.error("❌ 실시간 파일명 조회 중 오류: {}", e.getMessage());
                }
            }

            // ============================================================
            // 🚀 [실시간 전송] 이제 chatType과 fileName이 담긴 채로 소켓 전송됨!
            // ============================================================
            if (chatHandler != null) {
                // 🌟 여기서 chatLogVO 안에는 JS에서 보낸 'IMAGE'나 'FILE' 딱지가 들어있습니다.
                chatHandler.sendToRoom(chatLogVO.getChatRmNo(), chatLogVO);
                log.info("📢 [실시간 전송 완료] 타입: {}, 방번호: {}, 메시지 요약: {}", 
                         chatLogVO.getChatType(), chatLogVO.getChatRmNo(), 
                         chatLogVO.getChatCn().substring(0, Math.min(chatLogVO.getChatCn().length(), 20)));
            } else {
                log.error("🚨 chatHandler가 주입되지 않았습니다.");
            }

            // 🚩 [기존 반환 로직 유지]
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("data", chatLogVO); // 클라이언트에게 본인이 보낸 데이터 그대로 반환
            response.put("isSelfResponse", true); 

            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("fail");
        }
    }
    /**
     * 내가 참여 중인 채팅방 목록 조회
     */
    @GetMapping("/roomList")
    public ResponseEntity<?> getRoomList(Authentication auth) {
        if (auth == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();
        
        log.info("채팅방 목록 조회 요청 - 사원번호: {}", empId);
        
        // 서비스에서 해당 사원이 참여 중인 방 목록을 가져옵니다.
        // (기존에 만들어두신 selectChatRoomList 등을 활용하세요)
        List<ChatRoomVO> list = chatService.selectChatRoomList(empId); 
        
        return ResponseEntity.ok(list);
    }
    
    /**
     * [추가] 그룹 채팅용 전체 사원 목록 조회
     */
    @GetMapping("/allEmployees")
    public List<EmployeeVO> getAllEmployees() {
        log.info("그룹 채팅용 전체 사원 목록 조회");
        // 기존에 구현된 전체 사원 조회 서비스 호출
        return chatService.selectAllEmployeeList();
    }

    /**
     * [추가] 그룹 채팅방 생성 (AJAX용)
     */
    @ResponseBody
    @PostMapping("/createGroupRoom")
    public ResponseEntity<?> createGroupRoom(@RequestBody Map<String, Object> params, Authentication auth) {
        if (auth == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int myEmpId = customUser.getEmpVO().getEmpId();
        String myEmpNm = customUser.getEmpVO().getEmpNm(); // 발신자 이름 추가 활용

        // 1. 파라미터 추출
        String roomTitle = params.get("roomTitle").toString();
        List<?> rawList = (List<?>) params.get("memberList");
        List<Integer> memberList = rawList.stream()
                .map(obj -> Integer.parseInt(obj.toString()))
                .collect(Collectors.toList());

        log.info("그룹 채팅방 생성 요청 - 제목: {}, 참여인원: {}명", roomTitle, memberList.size());

        // 2. ChatRoomVO 설정
        ChatRoomVO chatRoomVO = new ChatRoomVO();
        chatRoomVO.setChatRmTtl(roomTitle);
        chatRoomVO.setEmpId(myEmpId);
        chatRoomVO.setChatRmType("GROUP");

        // 3. 방 생성 및 사용자 초대 서비스 호출
        chatService.createChatRoomWithUsers(chatRoomVO, memberList);

        // ============================================================
        // 🌟 [수정 로직] 그룹 채팅 알람 등록 (Mapper 직접 호출)
        // ============================================================
        try {
            List<Integer> invitees = new ArrayList<>(memberList);
            invitees.remove(Integer.valueOf(myEmpId)); // 나 제외

            if (!invitees.isEmpty() && this.alarmMapper != null) {
                // 1. 알람 마스터 등록 (AlarmVO)
                AlarmVO alarmVO = new AlarmVO();
                alarmVO.setEmpId(myEmpId);      // 보낸 사람 (VO 필드: empId)
                alarmVO.setAlmMsg("그룹 채팅 초대");
                alarmVO.setAlmDtl("<span class='fw-bold'>" + roomTitle + "</span> 채팅방에 초대되었습니다.");
                alarmVO.setAlmType("채팅");
                alarmVO.setAlmIcon("info");

                // 읽음 처리 시 인식할 URL 구성 (방 번호 포함)
                String chatRoomUrl = "/chat/main?chatRmNo=" + chatRoomVO.getChatRmNo();
                alarmVO.setAlmUrl(chatRoomUrl);

                // 알람 마스터 INSERT
                int result = alarmMapper.insertAlarm(alarmVO);
                
                if (result > 0) {
                    // 2. 수신자별 알람 등록 (AlarmReceiveVO)
                    for (int rcvrEmpId : invitees) {
                        AlarmReceiveVO receiveVO = new AlarmReceiveVO();
                        receiveVO.setAlmId(alarmVO.getAlmId()); // 생성된 알람 PK (almId)
                        receiveVO.setEmpId(rcvrEmpId);          // 수신자 사번 (VO 필드: empId)
                        receiveVO.setAlmYn("N");
                        
                        alarmMapper.insertAlarmReceive(receiveVO);
                    }
                    log.info("✅ [API] 그룹 채팅 알람 등록 완료 (방번호: {}, 알람ID: {})", chatRoomVO.getChatRmNo(), alarmVO.getAlmId());
                }
            }
        } catch (Exception e) {
            log.error("⚠️ [API] 그룹 채팅 알람 등록 실패: {}", e.getMessage());
        }
        // ============================================================

        return ResponseEntity.ok(chatRoomVO); 
    }
    
    /**
     * 특정 채팅방에 참여 중인 사원 목록 조회
     */
    @GetMapping("/roomParticipants")
    public ResponseEntity<List<ChatUserVO>> getRoomParticipants(@RequestParam("chatRmNo") int chatRmNo) {
        log.info("🚩 [API] 채팅방 참여자 조회 요청 - 방번호: {}", chatRmNo);
        
        // ChatController에서 이미 검증된 메서드를 그대로 사용합니다.
        List<ChatUserVO> userList = chatService.selectChatUserList(chatRmNo);
        
        return ResponseEntity.ok(userList);
    }
    
    /**
     * 채팅방 나가기 (퇴장 처리)
     */
    @PostMapping("/leaveRoom")
    public ResponseEntity<String> leaveRoom(@RequestBody Map<String, Object> params, Authentication authentication) {
        try {
            if (authentication == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

            // 1. 파라미터 및 사용자 정보 추출 (기존 로직 유지)
            int chatRmNo = Integer.parseInt(params.get("chatRmNo").toString());
            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            int myEmpId = userDetails.getEmpVO().getEmpId();
            String myEmpNm = userDetails.getEmpVO().getEmpNm();

            log.info("채팅방 퇴장 실행 - 방번호: {}, 사원번호: {}, 사원명: {}", chatRmNo, myEmpId, myEmpNm);

            // 2. 서비스 호출 (DB 처리 - 기존 로직 유지)
            chatService.leaveChatRoom(chatRmNo, myEmpId, myEmpNm);

            // ============================================================
            // 🌟 [실시간 전송 추가] 퇴장 메시지를 방 참여자들에게 즉시 전송
            // ============================================================
            // 🚩 주의: JS의 조건문(님이 채팅방을 나가셨습니다.)과 토씨 하나 안 틀리게 맞춰야 합니다.
            ChatLogVO leaveLog = new ChatLogVO();
            leaveLog.setChatRmNo(chatRmNo);
            leaveLog.setEmpId(myEmpId);
            leaveLog.setChatCn(myEmpNm + "님이 채팅방을 나가셨습니다.");
            leaveLog.setChatDt(new java.util.Date());

            // 소켓을 통해 실시간으로 쏴줍니다. (새로고침 없이 바로 뜸!)
            chatHandler.sendToRoom(chatRmNo, leaveLog);
            // ============================================================

            return ResponseEntity.ok("success");
        } catch (Exception e) {
            log.error("퇴장 처리 중 오류 발생: {}", e.getMessage());
            return ResponseEntity.internalServerError().body("fail: " + e.getMessage());
        }
    }
    
    @ResponseBody
    @PostMapping("/deleteRoom")
    public ResponseEntity<?> deleteChatRoom(@RequestParam("chatRmNo") int chatRmNo, Authentication auth) {
        if (auth == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();
        String empNm = customUser.getEmpVO().getEmpNm(); // 🚩 이름 정보 가져오기

        Map<String, Object> result = new HashMap<>();
        try {
            // 🚩 [수정] 서비스 정의에 맞게 empNm을 추가로 전달합니다.
            // 기존: chatService.leaveChatRoom(chatRmNo, empId); -> 에러 발생
            chatService.leaveChatRoom(chatRmNo, empId, empNm); 
            
            result.put("status", "success");
        } catch (Exception e) {
            result.put("status", "error");
            result.put("message", e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/download")
    public ResponseEntity<org.springframework.core.io.Resource> chatDownload(@RequestParam("fileId") Long fileId) {
        log.info("📂 [체크] 서버가 요청을 받았습니다! fileId: {}", fileId);
        return uploadController.downloadFile(fileId); 
    }


    // --------------------------------------------------------------------
    // [프로젝트 구성원 채팅]
    @PostMapping("/projectChatCreate")
    @ResponseBody
    public ChatRoomVO projectChatCreate(@RequestParam int targetId,
                                        @RequestParam String targetNm,
                                        Authentication auth) {
        CustomUser user = (CustomUser) auth.getPrincipal();
        int myEmpId = user.getEmpVO().getEmpId();
        String myEmpNm = user.getEmpVO().getEmpNm();

        log.info("[프로젝트 구성원] 채팅 연결 요청: {} -> {}", myEmpNm, targetNm);

        // 채팅 신규 생성
        ChatRoomVO room = chatService.projectChatCreate(myEmpId, myEmpNm, targetId, targetNm);

        return room;
    }
}