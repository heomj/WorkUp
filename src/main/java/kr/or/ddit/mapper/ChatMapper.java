package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Mapper;
import kr.or.ddit.vo.ChatRoomVO;
import kr.or.ddit.vo.ChatLogVO;
import kr.or.ddit.vo.ChatUserVO;
import kr.or.ddit.vo.EmployeeVO;

@Mapper
public interface ChatMapper {

    // ==========================================
    // 1. 채팅방(CHAT_ROOM) 관련
    // ==========================================

    /**
     * 새로운 채팅방 생성
     * XML의 <selectKey>를 통해 chatRoomVO에 CHAT_RM_NO가 세팅됨
     */
    public int insertChatRoom(ChatRoomVO chatRoomVO);

    /**
     * 특정 사원(empId)이 속한 채팅방 목록 조회
     */
    public List<ChatRoomVO> selectChatRoomList(int empId);

    /**
     * 특정 채팅방 번호로 방 정보 상세 조회
     */
    public ChatRoomVO selectChatRoomDetail(int chatRmNo);

    /**
     * 채팅방의 마지막 메시지 업데이트
     */
    public int updateLastMsg(ChatRoomVO chatRoomVO);


    // ==========================================
    // 2. 채팅 참여자(CHAT) 관련 (이미지상 테이블명 CHAT)
    // ==========================================

    /**
     * 채팅방에 참여자 추가
     */
    public int insertChatUser(ChatUserVO chatUserVO);

    /**
     * 특정 채팅방의 전체 참여자 목록 조회
     */
    public List<ChatUserVO> selectChatUserList(int chatRmNo);

    /**
     * 채팅방 생성을 위한 전체 사원 목록 조회
     */
    public List<EmployeeVO> selectAllEmployeeList();


    // ==========================================
    // 3. 채팅 로그(CHAT_LOG) 관련
    // ==========================================

    /**
     * 대화 내용(로그) 저장
     */
    public int insertChatLog(ChatLogVO chatLogVO);

    /**
     * 특정 채팅방의 이전 대화 내역 전체 조회
     */
    List<ChatLogVO> selectChatLogList(Map<String, Object> paramMap);
    
    public int updateChatRoomTitle(ChatRoomVO chatRoomVO);
    
    // 자식 삭제 1: 채팅 메시지 로그
    public int deleteChatLogs(int chatRmNo);
    
    // 자식 삭제 2: 참여자 명단
    public int deleteChatParticipants(int chatRmNo);
    
    // 부모 삭제: 채팅방 본체
    public int deleteChatRoom(int chatRmNo);
    
    String getFileNameByFileId(long fileId);
    
    /**
     * 채팅방 나만 나가기 (참여자 테이블에서 삭제)
     */
    public int leaveChatRoom(@Param("chatRmNo") int chatRmNo, @Param("empId") int empId);

    String getEmpNm(int empId);

    // [프로젝트 - 구성원]
    ChatRoomVO findRoomByTitle(@Param("title") String title, @Param("empId") int empId);

    // 추가된 것들
    int selectChatUserCount(int chatRmNo);
    
    int updateChatRoomStatus(ChatRoomVO chatRoomVO);
}