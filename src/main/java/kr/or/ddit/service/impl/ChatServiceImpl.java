package kr.or.ddit.service.impl;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

import kr.or.ddit.mapper.project.ProjectMemberMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.stream.Collectors;

import kr.or.ddit.mapper.AlarmMapper;
import kr.or.ddit.mapper.ChatMapper;
import kr.or.ddit.mapper.ItemMapper;
import kr.or.ddit.service.ChatService;
import kr.or.ddit.vo.ChatRoomVO;
import kr.or.ddit.vo.ChatLogVO;
import kr.or.ddit.vo.ChatUserVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.FileDetailVO;
import kr.or.ddit.vo.FileTbVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ChatServiceImpl implements ChatService {

    @Autowired
    private ChatMapper chatMapper;
    
    @Autowired
    private ItemMapper itemMapper; // 파일 관련 처리를 위해 추가

    @Value("${file.uploadFolder}")
    private String uploadFolder;
    
    @Autowired
    private AlarmMapper alarmMapper;
    
    
    /**
     * [채팅 전용] 파일 업로드 처리 로직
     * ChatServiceImpl 내부에 배치하거나, 컨트롤러에서 호출할 때 사용합니다.
     */
    private long handleChatFileUpload(MultipartFile[] multipartFiles, int empId) {
        // 1. 파일이 실제로 존재하는지 체크
        if (multipartFiles != null && multipartFiles.length > 0 && 
            !multipartFiles[0].getOriginalFilename().isEmpty()) {
            
            try {
                // 2. 앞서 만든 통합 메서드 호출
                // 이 안에서 FileTbVO 생성, 마스터 insert, 상세 insert가 모두 일어납니다.
                long newFileId = this.uploadChatFiles(multipartFiles, empId);
                
                log.info("채팅 파일 업로드 성공 - 생성된 FileID: {}", newFileId);
                return newFileId;
                
            } catch (Exception e) {
                log.error("채팅 파일 업로드 중 오류 발생: {}", e.getMessage());
                return 0L; // 실패 시 0 반환
            }
        }
        
        return 0L; // 업로드할 파일이 없는 경우
    }
    
    // 1. 사원 선택 창을 위한 전체 사원 목록 조회
    @Override
    public List<EmployeeVO> selectAllEmployeeList() {
        return chatMapper.selectAllEmployeeList();
    }

    // 2. 채팅방 개설 (방 생성 + 방장 등록 + 선택된 사원들 자동 초대)
    @Transactional
    @Override
    public int createChatRoomWithUsers(ChatRoomVO chatRoomVO, List<Integer> selectedUsers) {
        // [A] CHAT_ROOM 테이블에 방 정보 생성
        // selectKey에 의해 chatRoomVO 객체의 chatRmNo에 시퀀스 값이 세팅됩니다.
        int result = chatMapper.insertChatRoom(chatRoomVO);
        int newRoomNo = chatRoomVO.getChatRmNo();
        
        if(result > 0) {
            // [B] 방 개설자(본인)를 참여자(CHAT) 테이블에 '방장' 권한으로 등록
            ChatUserVO owner = new ChatUserVO();
            owner.setChatRmNo(newRoomNo);
            owner.setEmpId(chatRoomVO.getEmpId()); // 컨트롤러에서 principal로 세팅된 ID
            owner.setChatUserAuth("방장");
            // 이름(CHAT_USER_NM)은 Mapper에서 서브쿼리로 가져오도록 처리하거나 필요시 여기서 세팅
            chatMapper.insertChatUser(owner);
            
            // [C] 선택된 사원들을 참여자(CHAT) 테이블에 '일반' 권한으로 등록
            if(selectedUsers != null && !selectedUsers.isEmpty()) {
                for(int empId : selectedUsers) {
                    // 본인이 선택 목록에 포함되어 있어도 중복 등록되지 않게 처리
                    if(empId == chatRoomVO.getEmpId()) continue;

                    ChatUserVO member = new ChatUserVO();
                    member.setChatRmNo(newRoomNo);
                    member.setEmpId(empId);
                    member.setChatUserAuth("일반");
                    chatMapper.insertChatUser(member);
                }
            }
        }
        return newRoomNo;
    }

    // 3. 기존 단일 생성 메서드 (필요시 유지)
    @Transactional
    @Override
    public int createChatRoom(ChatRoomVO chatRoomVO) {
        int result = chatMapper.insertChatRoom(chatRoomVO);
        if(result > 0) {
            ChatUserVO owner = new ChatUserVO();
            owner.setChatRmNo(chatRoomVO.getChatRmNo());
            owner.setEmpId(chatRoomVO.getEmpId());
            owner.setChatUserAuth("방장");
            chatMapper.insertChatUser(owner);
        }
        return chatRoomVO.getChatRmNo();
    }

    // 4. 내 채팅방 목록 조회
    @Override
    public List<ChatRoomVO> selectChatRoomList(int empId) {
        return chatMapper.selectChatRoomList(empId);
    }

    // 5. 특정 채팅방 상세 정보
    @Override
    public ChatRoomVO selectChatRoomDetail(int chatRmNo) {
        return chatMapper.selectChatRoomDetail(chatRmNo);
    }

    // 6. 개별 멤버 추가 (채팅방 내부에서 초대 시 사용)
    @Override
    public int insertChatUser(ChatUserVO chatUserVO) {
        return chatMapper.insertChatUser(chatUserVO);
    }

    // 7. 채팅방 멤버 목록 조회
    @Override
    public List<ChatUserVO> selectChatUserList(int chatRmNo) {
        return chatMapper.selectChatUserList(chatRmNo);
    }

    // 8. 메시지 저장
    @Override
    public int insertChatLog(ChatLogVO chatLogVO) {
        // 1. [기존 로직] fileId가 0이나 음수면 null로 세팅해서 DB에 NULL이 들어가게 함
        if (chatLogVO.getFileId() != null && chatLogVO.getFileId() <= 0) {
            chatLogVO.setFileId(null);
        }

        // 2. [기존 로직] 메시지 본문 저장 실행
        // 이제 Mapper.xml에서 CHAT_TYPE 컬럼도 함께 저장하도록 수정되어야 합니다.
        int result = chatMapper.insertChatLog(chatLogVO);

        // 3. 🌟 [추가 로직] 채팅방 목록(Sidebar)의 '마지막 메시지' 업데이트
        // 사용자가 사진을 보냈을 때 목록에 Base64 코드가 뜨는 것을 방지합니다.
        if (result > 0) {
            ChatRoomVO roomVO = new ChatRoomVO();
            roomVO.setChatRmNo(chatLogVO.getChatRmNo());
            
            // 🌟 chatType 딱지에 따라 목록에 표시될 텍스트 결정
            String lastMsg = "";
            String type = chatLogVO.getChatType(); // VO에 추가하신 그 필드입니다.
            
            if ("IMAGE".equals(type)) {
                lastMsg = "사진을 보냈습니다.";
            } else if ("FILE".equals(type)) {
                lastMsg = "파일을 보냈습니다.";
            } else {
                // 일반 텍스트이거나 타입이 없을 경우 내용 그대로 표시
                lastMsg = chatLogVO.getChatCn();
            }
            
            // ChatRoomVO의 마지막 메시지 필드에 세팅
            roomVO.setChatRmLastMsg(lastMsg);
            
            // CHAT_ROOM 테이블의 CHAT_RM_LAST_MSG 컬럼 업데이트
            chatMapper.updateLastMsg(roomVO);
        }

        return result;
    }

    // 9. 이전 대화 내역 조회
    @Override
    @Transactional // 🌟 중요: 알람 업데이트와 메시지 조회를 하나의 트랜잭션으로 묶음
    public List<ChatLogVO> selectChatLogList(Map<String, Object> paramMap) {
        try {
            // 1. 파라미터 추출
            // Controller에서 넘겨준 loginEmpId와 chatRmNo를 사용
            Object loginIdObj = paramMap.get("loginEmpId");
            Object rmNoObj = paramMap.get("chatRmNo");

            if (loginIdObj != null && rmNoObj != null) {
                Map<String, Object> alarmParam = new HashMap<>();
                alarmParam.put("almRcvrNo", loginIdObj); // AlarmMapper.xml의 #{almRcvrNo}
                alarmParam.put("chatRmNo", rmNoObj);     // AlarmMapper.xml의 #{chatRmNo}
                
                // 2. 알람 읽음 처리 실행 (이게 실행되어야 새로고침 시 9+가 안 뜹니다)
                int updatedRows = alarmMapper.readChatAlarm(alarmParam);
                log.info("✅ 채팅방({}) 입장 - 알람 {}건 읽음 처리 완료", rmNoObj, updatedRows);
            }
        } catch (Exception e) {
            log.error("⚠️ 알람 읽음 처리 중 오류 발생(무시하고 메시지 로드): {}", e.getMessage());
        }

        // 3. 기존 메시지 리스트 조회 로직
        return chatMapper.selectChatLogList(paramMap);
    }
    
 // 1. 채팅방 제목 수정 로직
    @Override
    @Transactional // DB 수정이므로 트랜잭션 권장
    public int updateChatRoomTitle(ChatRoomVO chatRoomVO) {
        // 성공하면 1, 실패하면 0을 반환합니다.
        return chatMapper.updateChatRoomTitle(chatRoomVO);
    }

    // 2. 채팅방 삭제 로직
    @Override
    @Transactional
    public int deleteChatRoom(int chatRmNo) {
        log.info("🗑️ [채팅방 전체 삭제 시작] 방번호: {}", chatRmNo);

        try {
            // -----------------------------------------------------------
            // 🚩 [추가 로직] 해당 방과 관련된 모든 사용자의 알람을 읽음 처리
            // -----------------------------------------------------------
            // 방을 삭제하면 참여자 모두가 더 이상 알람을 지울 수 없으므로 
            // 해당 방 번호가 포함된 모든 채팅 알람을 'Y'로 바꿉니다.
            Map<String, Object> alarmParams = new HashMap<>();
            alarmParams.put("chatRmNo", chatRmNo);
            // 특정 empId를 넣지 않으면 해당 방의 모든 참여자 알람이 정리됩니다.
            // 만약 Mapper 쿼리에서 empId가 필수라면 현재 로그인한 사용자의 ID를 넣으세요.
            alarmMapper.readChatAlarm(alarmParams); 
            
            // 1. 자식 레코드들 먼저 삭제
            // 해당 방의 대화 내용 삭제
            chatMapper.deleteChatLogs(chatRmNo); 
            
            // 해당 방의 참여자 명단 삭제 (FK_CHAT_ROOM_TO_CHAT_1 관련)
            chatMapper.deleteChatParticipants(chatRmNo); 

            // 2. 마지막으로 부모인 채팅방 삭제
            int result = chatMapper.deleteChatRoom(chatRmNo);
            
            log.info("✅ [채팅방 전체 삭제 완료] 방번호: {}", chatRmNo);
            return result;
            
        } catch (Exception e) {
            log.error("❌ [채팅방 삭제 중 오류 발생] 방번호: {}. 원인: {}", chatRmNo, e.getMessage());
            throw e; // @Transactional에 의해 롤백됨
        }
    }
    
    @Override
    @Transactional // 여러 명을 넣을 때 오류 나면 롤백되도록 설정
    public void addChatUsers(int chatRmNo, List<Integer> inviteIdList) {
        if (inviteIdList == null || inviteIdList.isEmpty()) return;

        // 1. 입력받은 초대 리스트 자체에서 중복 ID 제거
        Set<Integer> uniqueInviteIds = new HashSet<>(inviteIdList);

        // 2. 현재 채팅방에 이미 참여 중인 멤버 목록 조회
        // ChatMapper의 selectChatUserList를 활용합니다.
        List<ChatUserVO> currentMembers = chatMapper.selectChatUserList(chatRmNo);
        
        // 기존 멤버들의 사번(empId)만 따로 추출하여 Set으로 저장 (비교 효율성 증대)
        Set<Integer> existingEmpIds = currentMembers.stream()
                                        .map(ChatUserVO::getEmpId)
                                        .collect(Collectors.toSet());

        for (int empId : uniqueInviteIds) {
            // 3. 이미 방에 존재하는 멤버인지 체크
            if (existingEmpIds.contains(empId)) {
                log.info("이미 참여 중인 사원 제외: {}", empId);
                continue; // 이미 있다면 다음 사원으로 건너뜀
            }

            // 4. 참여 중이 아닐 때만 신규 추가
            ChatUserVO vo = new ChatUserVO();
            vo.setChatRmNo(chatRmNo);
            vo.setEmpId(empId);
            
            // 참여자 권한을 '일반'으로 세팅
            vo.setChatUserAuth("일반");
            
            chatMapper.insertChatUser(vo);
        }
    }
    
    @Override
    public int updateLastMsg(ChatRoomVO chatRoomVO) {
        return chatMapper.updateLastMsg(chatRoomVO);
    }
    
    @Transactional
    @Override
    public void leaveChatRoom(int chatRmNo, int empId, String empNm) {
        
        // -----------------------------------------------------------
        // 🚩 [추가 로직 1] 방을 나가기 전, 해당 방과 관련된 모든 알람을 읽음 처리
        // -----------------------------------------------------------
        Map<String, Object> alarmParams = new HashMap<>();
        alarmParams.put("chatRmNo", chatRmNo);
        alarmParams.put("empId", empId);
        
        // AlarmMapper의 readChatAlarm을 호출하여 'N' 상태인 알람을 'Y'로 변경
        alarmMapper.readChatAlarm(alarmParams);
        log.info("🔔 [알람 정리] 사번 {}의 방 {} 관련 알람 읽음 처리 완료", empId, chatRmNo);

        // 1. [기존 로직] 참여자 삭제
        int deleteResult = chatMapper.leaveChatRoom(chatRmNo, empId);
        
        if (deleteResult > 0) {
            // 2. [기존 로직] 퇴장 시스템 메시지 저장
            ChatLogVO exitLog = new ChatLogVO();
            exitLog.setChatRmNo(chatRmNo);
            exitLog.setEmpId(empId);
            exitLog.setChatCn(empNm + "님이 채팅방을 나가셨습니다.");
            exitLog.setChatDt(new java.util.Date());
            
            chatMapper.insertChatLog(exitLog);
            
            // -----------------------------------------------------------
            // 🚩 [기존 로직] 자동 방 정리
            // -----------------------------------------------------------
            
            // 3. 남은 인원 체크
            int currentCount = chatMapper.selectChatUserCount(chatRmNo);
            
            if (currentCount == 0) {
                // 4. 마지막 인원이면 방 비활성화
                ChatRoomVO roomUpdate = new ChatRoomVO();
                roomUpdate.setChatRmNo(chatRmNo);
                roomUpdate.setChatRmYn("N");
                roomUpdate.setChatRmEndDt(new java.util.Date());
                
                chatMapper.updateChatRoomStatus(roomUpdate);
                log.info("🏠 [방 폐쇄 완료] 방번호: {}", chatRmNo);
            }
            
        } else {
            log.warn("⚠️ [퇴장 실패] 사번 {}은 방 {}의 멤버가 아님", empId, chatRmNo);
        }
    }
    /**
     * 채팅 파일 업로드 및 DB 기록
     * @param multipartFiles 실제 파일 배열
     * @param empId 등록자 사번
     * @return 생성된 fileId (파일 그룹 번호)
     */
    /**
     * [채팅 전용] 다중 파일 업로드 및 DB 기록
     * @param multipartFiles 컨트롤러에서 넘어온 파일 배열
     * @param empId 현재 로그인한 사원의 사번
     * @return 생성된 파일 그룹 번호(fileId). 파일이 없으면 0L 반환.
     */
    @Transactional
    @Override
    public long uploadChatFiles(MultipartFile[] multipartFiles, int empId) {
        // 1. 파일 존재 여부 체크 (게시판 로직의 안전장치 적용)
        if (multipartFiles == null || multipartFiles.length == 0 || 
            multipartFiles[0].getOriginalFilename().isEmpty()) {
            return 0L; 
        }

        log.info("📢 채팅 파일 업로드 시작 - 사번: {}, 파일수: {}", empId, multipartFiles.length);
        
        // 2. 파일 마스터(FileTbVO) 생성 및 저장
        FileTbVO fileTbVO = new FileTbVO();
        fileTbVO.setEmpId(empId);
        fileTbVO.setFileStts("CHAT"); // 채팅 파일 구분자
        
        // itemMapper.insertFileGroup 호출 (Mapper 내 selectKey를 통해 fileTbVO에 fileId가 세팅됨)
        itemMapper.insertFileGroup(fileTbVO);
        Long fileId = fileTbVO.getFileId();

        // 3. 개별 상세 파일 처리 루프
        for (MultipartFile multipartFile : multipartFiles) {
            if (multipartFile.isEmpty()) continue;

            // 폴더 생성 (yyyy-MM-dd 구조)
            String datePath = getFolder(); 
            File uploadPath = new File(this.uploadFolder, datePath);
            if (!uploadPath.exists()) {
                uploadPath.mkdirs();
            }

            // 파일명 중복 방지 (UUID + 원본파일명)
            String originalName = multipartFile.getOriginalFilename();
            String uuid = UUID.randomUUID().toString();
            String saveName = uuid + "_" + originalName;

            File saveFile = new File(uploadPath, saveName);
            
            try {
                // 물리 파일 저장
                multipartFile.transferTo(saveFile);
                
                // DB 저장용 웹 접근 경로 생성
                String webPath = "/" + datePath.replace(File.separator, "/") + "/" + saveName;

                // 4. 파일 상세(FileDetailVO) 설정 및 저장
                FileDetailVO detail = new FileDetailVO();
                detail.setFileId(fileId);        // 마스터 ID 연결 (FK)
                detail.setEmpId(empId);          // 등록자 사번
                detail.setFileDtlONm(originalName);
                detail.setFileDtlSaveNm(saveName);
                detail.setFileDtlPath(webPath);
                
                // 확장자 추출
                String ext = "";
                if (originalName != null && originalName.contains(".")) {
                    ext = originalName.substring(originalName.lastIndexOf(".") + 1);
                }
                detail.setFileDtlExt(ext);

                // 상세 테이블 INSERT
                itemMapper.insertFileDetail(detail);

            } catch (IOException e) {
                log.error("❌ 파일 저장 중 물리적 에러 발생: {}", e.getMessage());
                // @Transactional이 설정되어 있으므로 RuntimeException을 던져야 DB 작업이 롤백됩니다.
                throw new RuntimeException("파일 업로드 프로세스 실패", e); 
            }
        }

        log.info("✅ 채팅 파일 업로드 완료 - 생성된 그룹 ID: {}", fileId);
        return fileId;
    }

    /**
     * 연-월-일 폴더 경로 생성 (유틸리티)
     */
    private String getFolder() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new Date()).replace("-", File.separator);
    }


    // [프로젝트 - 구성원]
    @Override
    public ChatRoomVO getChatRoomByTitle(String title, int empId) {
        return chatMapper.findRoomByTitle(title, empId);
    }
    
    @Override
    public String getEmpName(List<Integer> inviteIdList) {
        if (inviteIdList == null || inviteIdList.isEmpty()) {
            return "";
        }

        // 1. 사번 리스트를 이용해 사원 정보(VO) 리스트를 가져옵니다.
        // (기존에 사원 정보를 가져오는 mapper 메서드가 있다면 활용하세요)
        // 여기서는 스트림을 사용해 이름을 뽑아내고 ","로 연결합니다.
        return inviteIdList.stream()
                .map(empId -> {
                    // 각 사번으로 이름을 가져오는 로직 (예: Mapper 호출)
                    // 만약 mapper에 단건 조회 기능이 없다면 아래처럼 작성하거나 
                    // 전체 리스트 조회를 활용하세요.
                    return chatMapper.getEmpNm(empId); 
                })
                .filter(Objects::nonNull)
                .collect(Collectors.joining(", "));
    }



    // [프로젝트 - 구성원] --------------------------------------------------------------------

    @Autowired
    private ProjectMemberMapper projectMemberMapper;


    @Override
    @Transactional
    public ChatRoomVO projectChatCreate(int myId, String myNm, int targetId, String targetNm) {
        // 1. 기존 1:1 방 조회
        ChatRoomVO room = projectMemberMapper.findDirectRoom(myId, targetId);

        if (room == null) {
            // 2. 방이 없다면 신규 생성 (기존 ChatMapper 활용)
            room = new ChatRoomVO();
            room.setChatRmTtl(targetNm);
            room.setChatRmType("1"); // 1:1 채팅
            chatMapper.insertChatRoom(room); // selectKey에 의해 roomNo 채워짐

            // 3. 참여자 등록 (신규 매퍼 활용)
            // 나를 방장으로 추가
            projectMemberMapper.insertChatMember(room.getChatRmNo(), myId, "방장");
            // 상대방을 일반 참여자로 추가
            projectMemberMapper.insertChatMember(room.getChatRmNo(), targetId, "참여자");
        }

        return room;
    }
    
    @Override
    public String getFileNameByFileId(long fileId) {
        return chatMapper.getFileNameByFileId(fileId);
    }
    
}