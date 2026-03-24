package kr.or.ddit.service;

import java.util.List;
import java.util.Map;
import org.springframework.web.multipart.MultipartFile;
import kr.or.ddit.vo.BoardVO;

public interface BoardService {
	
	// 1. 부서별 게시판 등록 (첨부파일 처리 로직 포함)
	public int insertBoard(BoardVO boardVO, MultipartFile[] uploadFile);
	
	// 2. 부서별 게시판 상세 조회 (조회수 증가 로직 포함)
	public BoardVO selectBoardDetail(int bbsNo);
	
	// 2-1. [추가] 상세 페이지를 위한 통합 조회 (본문 + 댓글 + 파일 합치기)
    // 컨트롤러에서는 이 메서드를 호출하면 됩니다.
    public BoardVO selectBoardDetailAll(int bbsNo);

    // 2-2. [추가] 댓글 목록 조회 (ServiceImpl 내부에서 호출 및 컨트롤러 재사용용)
    public List<kr.or.ddit.vo.CommentVO> selectCommentList(int bbsNo);

    // 2-3. [추가] 파일 상세 목록 조회 (ServiceImpl 내부에서 호출)
    public List<kr.or.ddit.vo.FileDetailVO> selectFileList(Long fileId);
	
	// 3. 부서별 게시판 목록 조회 (검색 및 페이징 파라미터 포함)
	public List<BoardVO> selectBoardList(Map<String, Object> map);
	
	// 4. 전체 부서별 게시판 행의 수 조회 (페이징 처리를 위함)
	public int selectBoardCount(Map<String, Object> map);
	
	// 5. 부서별 게시판 수정 실행
	public int updateBoard(BoardVO boardVO);
	
	// 6. 부서별 게시판 삭제 실행
	public int deleteBoard(int bbsNo);
	
	// 7. 조회수 증가 (단독 호출용)
	public int incrementViewCount(int bbsNo);

	// 8. 게시물 통합 액션 처리 (좋아요/싫어요/추천 등록 및 취소 로직 통합)
	// 컨트롤러에서 이 메서드 하나만 호출하면 장부 확인부터 카운트 증감까지 한 번에 해결되네.
	public Map<String, Object> processBoardAction(int bbsNo, int empId, String actionType);

	// 9. 좋아요 카운트 증가
	public int incrementLikeCount(int bbsNo);
	
	// 10. 좋아요 카운트 감소 (취소 시)
	public int decrementLikeCount(int bbsNo);
	
	// 11. 싫어요 카운트 증가
	public int incrementDislikeCount(int bbsNo);
	
	// 12. 싫어요 카운트 감소 (취소 시)
	public int decrementDislikeCount(int bbsNo);
	
	// 13. 추천 카운트 증가
	public int incrementRecomCount(int bbsNo);
	
	// 14. 추천 카운트 감소 (취소 시)
	public int decrementRecomCount(int bbsNo);
	
	// 15. 사용자가 해당 게시물에 특정 액션(LIKE/DISLIKE/RECOM)을 이미 했는지 확인
	public int checkUserAction(Map<String, Object> map);

	// 16. 게시물 반응 장부(BOARD_ACTIONS)에 기록 추가
	public int insertUserAction(Map<String, Object> map);

	// 17. 게시물 반응 장부(BOARD_ACTIONS)에서 기록 삭제 (취소 시)
	public int deleteUserAction(Map<String, Object> map);

	// 18. 상세페이지 로드 시 해당 사용자가 이 게시글에 남긴 모든 반응 리스트 조회
	public List<String> selectUserActionList(Map<String, Object> map);
}