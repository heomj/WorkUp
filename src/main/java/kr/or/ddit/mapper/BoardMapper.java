package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import kr.or.ddit.vo.BoardVO;

@Mapper
public interface BoardMapper {
	
	// 1. 부서별 게시판 등록
	public int insertBoard(BoardVO boardVO);
	
	// 2. 부서별 게시판 상세 조회
	public BoardVO selectBoardDetail(int bbsNo);
	
	// 3. 부서별 게시판 목록 조회 (검색 및 페이징 포함)
	public List<BoardVO> selectBoardList(Map<String, Object> map);
	
	// 4. 전체 부서별 게시판 행의 수 조회
	public int selectBoardCount(Map<String, Object> map);
	
	// 5. 부서별 게시판 수정 실행
	public int updateBoard(BoardVO boardVO);
	
	// 6. 부서별 게시판 삭제 실행
	public int deleteBoard(int bbsNo);
	
	// 7. 조회수 증가
	public int incrementViewCount(int bbsNo);

	// --- [파일 및 작성자 관련 추가 메서드] ---

	// 8. 기존 첨부파일 개별 삭제 (수정 시 사용)
	public int deleteFileDetail(String fileDtlId);
	
	// 9. 기존 파일들을 새로운 FILE_ID 그룹으로 이동
	public int migrateFiles(Map<String, Object> map);
	
	// 10. 게시글 번호로 작성자의 사번(EMP_ID) 조회 (본인 확인용)
	public int getBoardWriterId(int bbsNo);

	// --- [게시물 반응: 좋아요/싫어요/추천 카운트 증감] ---

	// 11. 좋아요 카운트 증가
	public int incrementLikeCount(int bbsNo);
	
	// 12. 좋아요 카운트 감소
	public int decrementLikeCount(int bbsNo);
	
	// 13. 싫어요 카운트 증가
	public int incrementDislikeCount(int bbsNo);
	
	// 14. 싫어요 카운트 감소
	public int decrementDislikeCount(int bbsNo);
	
	// 15. 추천 카운트 증가
	public int incrementRecomCount(int bbsNo);
	
	// 16. 추천 카운트 감소
	public int decrementRecomCount(int bbsNo);

	// --- [게시물 반응: BOARD_ACTIONS 장부 관리] ---
	
	// 17. 사용자가 특정 액션(LIKE/DISLIKE/RECOM)을 했는지 장부에서 확인 (결과: 1 또는 0)
	public int checkUserAction(Map<String, Object> map);

	// 18. 게시물 반응 장부(BOARD_ACTIONS)에 기록 추가
	public int insertUserAction(Map<String, Object> map);

	// 19. 게시물 반응 장부(BOARD_ACTIONS)에서 기록 삭제 (취소 시)
	public int deleteUserAction(Map<String, Object> map);

	// 20. 사용자가 이 게시글에 남긴 모든 반응 리스트 조회 (상세페이지 로드 시 버튼 상태 결정)
	public List<String> selectUserActionList(Map<String, Object> map);
	
	// 21. 해당 게시글의 댓글 목록 조회 (XML의 selectCommentList와 연결)
    public List<kr.or.ddit.vo.CommentVO> selectCommentList(int bbsNo);

    // 22. 해당 게시글의 파일 목록 조회 (XML의 selectFileList와 연결)
    // 파라미터 타입은 XML의 parameterType과 일치해야 합니다 (String 또는 Long)
    public List<kr.or.ddit.vo.FileDetailVO> selectFileList(String fileId);
}