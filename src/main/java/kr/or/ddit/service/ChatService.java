package kr.or.ddit.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.vo.ChatRoomVO;
import kr.or.ddit.vo.ChatLogVO;
import kr.or.ddit.vo.ChatUserVO;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.FileTbVO;

public interface ChatService {
    
    // ==========================================
    // 1. 채팅방(CHAT_ROOM) 관련
    // ==========================================
    
    /**
     * 채팅방 개설 및 선택된 사원들 일괄 초대 (트랜잭션 처리)
     * @param chatRoomVO 채팅방 정보 (방 제목, 방 타입 등)
     * @param selectedUsers 선택된 사원 번호(EMP_ID) 리스트
     * @return 생성된 채팅방 번호(CHAT_RM_NO)
     */
    public int createChatRoomWithUsers(ChatRoomVO chatRoomVO, List<Integer> selectedUsers);

    /**
     * 채팅방 기본 정보 개설 (단일)
     */
    public int createChatRoom(ChatRoomVO chatRoomVO);

    /**
     * 로그인한 사원이 참여 중인 채팅방 목록 조회
     */
    public List<ChatRoomVO> selectChatRoomList(int empId);

    /**
     * 특정 채팅방의 상세 정보 조회
     */
    public ChatRoomVO selectChatRoomDetail(int chatRmNo);

    
    // ==========================================
    // 2. 채팅 참여자(CHAT) 관련
    // ==========================================
    
    /**
     * 채팅방에 새로운 멤버 추가
     */
    public int insertChatUser(ChatUserVO chatUserVO);

    /**
     * 특정 채팅방에 참여 중인 멤버 목록 조회
     */
    public List<ChatUserVO> selectChatUserList(int chatRmNo);

    /**
     * 채팅방 개설 시 초대 가능한 전체 사원 목록 조회
     */
    public List<EmployeeVO> selectAllEmployeeList();

    
    // ==========================================
    // 3. 채팅 로그(CHAT_LOG) 관련
    // ==========================================
    
    /**
     * 채팅 메시지(로그) 저장
     */
    public int insertChatLog(ChatLogVO chatLogVO);

    /**
     * 특정 채팅방의 이전 대화 내역 조회
     */
    List<ChatLogVO> selectChatLogList(Map<String, Object> paramMap);
    
    public int updateChatRoomTitle(ChatRoomVO chatRoomVO);
    
    public int deleteChatRoom(int chatRmNo);
    
    public void addChatUsers(int chatRmNo, List<Integer> inviteIdList);
    
    public int updateLastMsg(ChatRoomVO chatRoomVO);
    
    /**
     * 채팅방에서 특정 사용자만 퇴장 처리 (참여자 목록에서 삭제)
     * @param chatRmNo 방 번호
     * @param empId 나가는 사원 번호
     * @return 삭제된 행 수
     */
    public void leaveChatRoom(int chatRmNo, int empId, String empNm);

    String getEmpName(List<Integer> inviteIdList);
    
    // [추가] 파일 업로드 및 DB 기록
    long uploadChatFiles(MultipartFile[] multipartFiles, int empId);
    
    String getFileNameByFileId(long fileId);

    /**
     * 동일한 채팅방의 이름이 있는지 찾기
     */
    ChatRoomVO getChatRoomByTitle(String title, int empId);

    // [프로젝트 - 구성원]
    /**
     * 동일한 채팅방의 이름이 있는지 찾기
     */
    public ChatRoomVO projectChatCreate(int myId, String myNm, int targetId, String targetNm);

}