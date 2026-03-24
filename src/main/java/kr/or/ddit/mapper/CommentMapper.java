package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import kr.or.ddit.vo.CommentVO;

@Mapper
public interface CommentMapper {
    // 댓글 목록 조회
    public List<CommentVO> selectCommentList(int bbsNo);
    
    // 댓글 등록
    public int insertComment(CommentVO commentVO);
    
    // 댓글 수정
    public int updateComment(CommentVO commentVO);
    
    // 댓글 논리 삭제
    public int deleteComment(int cmntNo);

    // 좋아요 여부 확인 (있으면 1, 없으면 0)
    public int checkLikeExists(Map<String, Object> map);

    // 좋아요 추가
    public int insertLike(Map<String, Object> map);

    // 좋아요 취소
    public int deleteLike(Map<String, Object> map);
    
    // 추가: 댓글 상세 정보 가져오기
    public CommentVO selectCommentDetail(int cmntNo);
}