package kr.or.ddit.controller;

import java.security.Principal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import kr.or.ddit.service.impl.CustomUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.or.ddit.service.ChatService;
import kr.or.ddit.util.AlarmController;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.ChatLogVO;
import kr.or.ddit.vo.ChatRoomVO;
import kr.or.ddit.vo.ChatUserVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/chat")
public class ChatController {

    @Autowired
    private ChatService chatService;
    
    //알람 발송
    @Autowired
    private AlarmController alarmController;

    /**
     * 채팅 목록 조회
     */
    @GetMapping("/list")
    public String chatMain(Principal principal, Model model) {
        if (principal == null) return "redirect:/login";
        
        int empId = Integer.parseInt(principal.getName());
        // Service: selectChatRoomList 사용
        List<ChatRoomVO> roomList = chatService.selectChatRoomList(empId);
        
        model.addAttribute("roomList", roomList);
        model.addAttribute("contentPage", "chat/list"); 
        return "main"; 
    }

    /**
     * 채팅방 생성 폼 이동
     */
    @GetMapping("/create")
    public String createRoomForm(Principal principal, Model model) {
        if (principal == null) return "redirect:/login";
        
        int myEmpId = Integer.parseInt(principal.getName());
        List<EmployeeVO> userList = chatService.selectAllEmployeeList();
        
        model.addAttribute("userList", userList);
        model.addAttribute("loginId", myEmpId); // 본인 식별을 위해 추가
        model.addAttribute("contentPage", "chat/create");
        return "main";
    }

    /**
     * 채팅방 생성 실행
     */
    @PostMapping("/create")
    public String createRoom(ChatRoomVO chatRoomVO, 
                             @RequestParam(value="empIds", required=false) List<Integer> selectedUsers, 
                             Principal principal) {
        if (principal == null) return "redirect:/login";
        
        int myEmpId = Integer.parseInt(principal.getName());
        chatRoomVO.setEmpId(myEmpId);
        
        List<Integer> uniqueUsers = new ArrayList<>();
        if (selectedUsers != null && !selectedUsers.isEmpty()) {
            Set<Integer> userSet = new HashSet<>(selectedUsers);
            userSet.remove(myEmpId);
            uniqueUsers = new ArrayList<>(userSet);
        }

        // 1. 채팅방 생성 및 사용자 초대 (기존 로직)
        // chatRoomVO에 생성된 방 번호(chatRmNo)가 담겨와야 알람 URL을 만들 수 있습니다.
        chatService.createChatRoomWithUsers(chatRoomVO, uniqueUsers);
        
        // 2. [알람 로직 추가] 초대된 사람들에게 실시간 알람 전송
        if (!uniqueUsers.isEmpty()) {
            try {
                AlarmVO alarmVO = new AlarmVO();
                
                // 현재 로그인한 사람 정보 (보내는 사람)
                // 서비스나 컨트롤러에서 현재 사용자의 이름/직급을 가져오는 로직이 필요합니다.
                // 예시: CustomUser userDetails = (CustomUser) authentication.getPrincipal();
                
                alarmVO.setAlmMsg("새로운 채팅방 초대");
                alarmVO.setAlmDtl(
                    "<span class=\"fw-bold\">새로운 채팅방</span>에 초대되었습니다. 지금 확인해보세요!");
                
                // 중복 제거된 초대 명단(uniqueUsers)을 통째로 수신자로 설정
                alarmVO.setAlmRcvrNos(uniqueUsers); 
                alarmVO.setAlmIcon("chat");

                // 알람 클릭 시 이동할 URL (생성된 방 번호 이용)
                String chatRoomUrl = "/chat/room?chatRmNo=" + chatRoomVO.getChatRmNo();

                // 알람 컨트롤러 호출
                this.alarmController.sendAlarm(
                    myEmpId,
                    alarmVO,
                    chatRoomUrl,
                    "채팅"
                );
            } catch (Exception e) {
                log.error("채팅방 생성 알람 전송 실패: {}", e.getMessage());
            }
        }
        
        return "redirect:/chat/list";
    }

    /**
     * 특정 채팅방 입장
     */
    @GetMapping("/room")
    public String chatRoom(@RequestParam("chatRmNo") int chatRmNo, Model model, Principal principal) {
        if (principal == null) {
            log.warn("⚠️ 미인증 사용자 접근");
            return "redirect:/login";
        }

        // 변수를 try 블록 밖에서 미리 선언해두면 하단 model.addAttribute에서도 안전하게 쓸 수 있습니다.
        int myEmpId = 0;
        
        try {
            // principal에서 ID 추출
            myEmpId = Integer.parseInt(principal.getName());

            // ---------------------------------------------------------
            // [🔥 실시간 알람 읽음 처리 수정]
            // "Y" 대신 실행할 MyBatis SQL ID인 "readChatAlarm"을 넘겨줍니다.
            // ---------------------------------------------------------
            try {
                if (this.alarmController != null) {
                    Map<String, Object> updateMap = new java.util.HashMap<>();
                    updateMap.put("almRcvrNo", myEmpId);    
                    
                    updateMap.put("updateStts", "readChatAlarm"); 
                    
                    updateMap.put("chatRmNo", chatRmNo);    

                    this.alarmController.updateStts(updateMap); 
                    log.info("✅ 채팅방({}) 입장 시 알람 읽음 처리 완료", chatRmNo);
                }
            } catch (Exception alarmEx) {
                // 알람 처리 실패가 채팅방 입장 자체를 막지 않도록 로그만 남깁니다.
                log.error("⚠️ 알람 상태 업데이트 중 오류 발생(무시하고 입장 진행): {}", alarmEx.getMessage());
            }
            // ---------------------------------------------------------

            // 1. 내 정보 가져오기
            String myEmpNm = "사용자"; 
            String myEmpProfile = "default-avatar.png"; 
            
            List<EmployeeVO> allEmp = chatService.selectAllEmployeeList();
            if (allEmp != null) {
                for(EmployeeVO vo : allEmp) {
                    if(vo.getEmpId() == myEmpId) {
                        myEmpNm = vo.getEmpNm();
                        myEmpProfile = (vo.getEmpProfile() != null) ? vo.getEmpProfile() : "default-avatar.png"; 
                        break;
                    }
                }
            }

            // 2. 채팅방 데이터 조회
            ChatRoomVO roomDetail = chatService.selectChatRoomDetail(chatRmNo);
            if (roomDetail == null) return "redirect:/chat/list";

            List<ChatUserVO> userList = chatService.selectChatUserList(chatRmNo);

            // 🌟 [핵심 수정 부분] 🌟
            // 서비스 인터페이스가 Map을 받도록 바뀌었으므로, 여기서 Map을 만들어줍니다.
            java.util.Map<String, Object> paramMap = new java.util.HashMap<>();
            paramMap.put("chatRmNo", chatRmNo);
            paramMap.put("loginEmpId", myEmpId); // 👈 이게 있어야 내 입장 시간 이후만 가져옴

            // 이제 에러 밑줄이 사라질 거예요!
            List<ChatLogVO> logList = chatService.selectChatLogList(paramMap);
            
            // 3. JSP 데이터 매핑
            model.addAttribute("loginId", myEmpId);
            model.addAttribute("loginNm", myEmpNm);
            model.addAttribute("loginProfile", myEmpProfile); 
            
            model.addAttribute("room", roomDetail);
            model.addAttribute("chatList", logList);
            model.addAttribute("memList", userList);
            model.addAttribute("room", roomDetail);
            model.addAttribute("contentPage", "chat/room");
            
            return "main";
            
        } catch (Exception e) {
            log.error("🔥 채팅방 로딩 중 치명적 오류: ", e); 
            return "redirect:/chat/list";
        }
    }
    
    /**
     * 채팅방 제목 수정 (AJAX)
     */
    @PostMapping("/updateTitle")
    @ResponseBody
    public ResponseEntity<String> updateTitle(@RequestBody ChatRoomVO chatRoomVO) {
        // 인터페이스: updateChatRoomTitle 사용
        int result = chatService.updateChatRoomTitle(chatRoomVO);
        return result > 0 ? ResponseEntity.ok("success") : ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("fail");
    }

    /**
     * 채팅방 삭제/나가기 (AJAX)
     */
    @PostMapping("/delete")
    @ResponseBody
    public ResponseEntity<String> deleteRoom(@RequestBody Map<String, Object> params) {
        try {
            int chatRmNo = Integer.parseInt(params.get("chatRmNo").toString());
            // 인터페이스: deleteChatRoom 사용
            int result = chatService.deleteChatRoom(chatRmNo);
            return result > 0 ? ResponseEntity.ok("success") : ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("fail");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("error");
        }
    }
    
    /**
     * 채팅방 나가기 (참여자 본인만 삭제)
     */
    @PostMapping("/leave")
    @ResponseBody
    public ResponseEntity<String> leaveRoom(@RequestBody Map<String, Object> params, Authentication authentication) {
        try {
            // 1. 로그인 체크 및 사용자 정보 확보 (기존 로직)
            if (authentication == null) return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

            CustomUser userDetails = (CustomUser) authentication.getPrincipal();
            int empId = userDetails.getEmpVO().getEmpId();
            String empNm = userDetails.getEmpVO().getEmpNm();

            // 2. 나가는 방 번호 확보 (기존 로직)
            int chatRmNo = Integer.parseInt(params.get("chatRmNo").toString());

            log.info("🚪 채팅방 퇴장 요청 - 방번호: {}, 사번: {}, 이름: {}", chatRmNo, empId, empNm);

            // 3. Service 호출 (참여자 삭제 - 기존 로직)
            chatService.leaveChatRoom(chatRmNo, empId, empNm);

            // ============================================================
            // 🌟 [추가 로직] "누구님이 퇴장하셨습니다" 시스템 메시지 저장
            // ============================================================
            ChatLogVO leaveLog = new ChatLogVO();
            leaveLog.setChatRmNo(chatRmNo);
            leaveLog.setEmpId(empId); // 퇴장하는 사람 사번
            leaveLog.setChatCn(empNm + "님이 채팅방을 나가셨습니다."); // JS가 인식할 핵심 문구
            leaveLog.setChatDt(new java.util.Date());
            
            // DB에 로그 저장
            chatService.insertChatLog(leaveLog);

            // ⚠️ 참고: 만약 다른 참여자들에게 '실시간'으로 나갔음을 알리려면 
            // 여기서 WebSocket 전송 로직이 추가로 필요할 수 있습니다.
            // ============================================================

            return ResponseEntity.ok("success");
        } catch (Exception e) {
            log.error("❌ 채팅방 퇴장 중 오류 발생: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("error");
        }
    }





    /**
     * 구성원 목록에서 즉시 1:N(실질적 1:1) 채팅방 생성 및 입장
     */
    @PostMapping("/createDirect")
    public String createFromMember(ChatRoomVO chatRoomVO, Authentication auth) {
        if (auth == null) return "redirect:/login";

        // 작성자 정보 설정
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();
        chatRoomVO.setEmpId(empId);
        chatRoomVO.setChatRmType("GROUP");

        // 1. 기존 채팅방 존재 여부 확인
        ChatRoomVO existingRoom = chatService.getChatRoomByTitle(chatRoomVO.getChatRmTtl(), empId);

        if (existingRoom != null) {
            log.info("이미 동일한 제목의 채팅방이 존재함: 번호 {}", existingRoom.getChatRmNo());
            // 새로 생성하지 않고 기존 방으로 이동
            return "redirect:/chat/room?chatRmNo=" + existingRoom.getChatRmNo();
        }

        // 2. 존재하지 않는 경우에만 새로 생성 ( 참여자 - 상대방 추가)
        List<Integer> uniqueUsers = new ArrayList<>();
        if (chatRoomVO.getTargetId() != 0) {
            uniqueUsers.add(chatRoomVO.getTargetId());
        }

        chatService.createChatRoomWithUsers(chatRoomVO, uniqueUsers);

        // 알람 발송
        if (!uniqueUsers.isEmpty()) {
            try {
                AlarmVO alarmVO = new AlarmVO();
                alarmVO.setAlmMsg("새로운 채팅방 초대");
                alarmVO.setAlmDtl("<span class='fw-bold'>" + chatRoomVO.getChatRmTtl() + "</span> 채팅방에 초대되었습니다.");
                alarmVO.setAlmRcvrNos(uniqueUsers);
                alarmVO.setAlmIcon("chat");

                // 생성된 방 번호로 URL 생성
                String chatRoomUrl = "/chat/room?chatRmNo=" + chatRoomVO.getChatRmNo();
                this.alarmController.sendAlarm(empId, alarmVO, chatRoomUrl, "채팅");
            } catch (Exception e) {
                log.error("채팅 생성 알람 전송 실패: {}", e.getMessage());
            }
        }

        // 생성된 채팅방으로 이동
        return "redirect:/chat/room?chatRmNo=" + chatRoomVO.getChatRmNo();
    }


}