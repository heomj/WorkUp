package kr.or.ddit.service;

import java.util.List;
import java.util.Map;
import kr.or.ddit.vo.CommentVO;

public interface CommentService {
    // 1. 특정 게시글의 댓글 목록 조회
    public List<CommentVO> selectCommentList(int bbsNo);
    
    // 2. 댓글 등록 후 최신 목록 반환 (자네가 보여준 registBoardReplyAxios 패턴)
    public List<CommentVO> insertCommentAndList(CommentVO commentVO);
    
    // 3. 댓글 수정 후 최신 목록 반환 (editBoardReplyPost 패턴)
    public List<CommentVO> updateCommentAndList(CommentVO commentVO);
    
    // 4. 댓글 삭제 후 최신 목록 반환 (removeBoardReply 패턴)
    public List<CommentVO> deleteCommentAndList(CommentVO commentVO);

    // 5. 좋아요 토글 (성공 여부나 결과 카운트 반환)
    public int toggleCommentLike(Map<String, Object> map);
    
    // 댓글 단건 상세 조회 (알람 발송 및 정보 확인용) 추가
    public CommentVO selectCommentDetail(int cmntNo);
}