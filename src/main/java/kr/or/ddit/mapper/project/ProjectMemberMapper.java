package kr.or.ddit.mapper.project;

import kr.or.ddit.vo.ChatRoomVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.PrtpntVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ProjectMemberMapper {

    // 프로젝트 참여자 리스트 조회
    public List<PrtpntVO> memberStatus(int projNo);

    // 업무능력별 참여자 리스트 조회
    public List<PrtpntVO> memberTaskStatus(int projNo);

    // 프로젝트명 가져오기
    public ProjectVO projectTitle(int projNo);

    // 채팅
    /**
     * 나와 상대방이 정확히 참여하고 있는 1:1 채팅방 조회
     */
    public ChatRoomVO findDirectRoom(@Param("myId") int myId, @Param("targetId") int targetId);

    /**
     * 채팅방 참여자 추가
     */
    public int insertChatMember(@Param("chatRmNo") int chatRmNo,
                       @Param("empId") int empId,
                       @Param("chatUserAuth") String chatUserAuth);
}
