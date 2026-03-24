package kr.or.ddit.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.mapper.BoardMapper;
import kr.or.ddit.mapper.ComplaintMapper;
import kr.or.ddit.service.BoardService;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.BoardVO;
import kr.or.ddit.vo.CommentVO;
import kr.or.ddit.vo.FileDetailVO;
import kr.or.ddit.vo.FileTbVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class BoardServiceImpl implements BoardService {
	
	@Autowired
	private UploadController uploadController;
	
	@Autowired
	private BoardMapper boardMapper;
	
	@Autowired
	private ComplaintMapper complaintMapper;
	
	/**
	 * [공통 메서드] 파일 업로드 처리 내부 로직
	 */
	private long handleFileUpload(BoardVO boardVO, long existingFileId) {
		MultipartFile[] multipartFiles = boardVO.getUploadFiles(); 
		
		if(multipartFiles != null && multipartFiles.length > 0 &&
		   !multipartFiles[0].getOriginalFilename().isEmpty()) {
			
			FileTbVO fileGroupVO = new FileTbVO();
			fileGroupVO.setEmpId(boardVO.getEmpId()); 
			fileGroupVO.setFileStts("자료실"); 
			
			if (existingFileId > 0) {
				fileGroupVO.setFileId(existingFileId);
			}
			
			Long resultFileId = this.uploadController.multiFileUpload(multipartFiles, fileGroupVO);
			return (resultFileId != null) ? resultFileId : existingFileId;
		}
		return existingFileId; 
	}

	// 1. 부서별 게시판 등록 (첨부파일 처리 로직 포함)
	@Transactional
	@Override
	public int insertBoard(BoardVO boardVO, MultipartFile[] uploadFile) {
		if (uploadFile != null && uploadFile.length > 0 && !uploadFile[0].isEmpty()) {
			boardVO.setUploadFiles(uploadFile);
			long fileId = handleFileUpload(boardVO, 0L); 
			if(fileId > 0) {
				boardVO.setFileId(fileId);
			}
		} else {
			boardVO.setFileId(0L); 
		}
		log.info("insert 직전 fileId 체크: {}", boardVO.getFileId());
		return this.boardMapper.insertBoard(boardVO);
	}

	// 2. 부서별 게시판 상세 조회 (통합 조립 버전)
    @Override
    public BoardVO selectBoardDetailAll(int bbsNo) {
        // 1) 게시글 본문 정보 가져오기
        // (Mapper 인터페이스의 selectBoardDetail이 int를 받도록 되어있는지 확인!)
        BoardVO boardVO = boardMapper.selectBoardDetail(bbsNo);
        
        if(boardVO != null) {
            // 2) 댓글 리스트 조회 및 세팅
            List<CommentVO> commentList = boardMapper.selectCommentList(bbsNo);
            boardVO.setCommentVOList(commentList);
            
            // 3) 파일 리스트 조회 및 세팅
            // fileId가 String이라면 .isEmpty() 사용, Long/Integer라면 0보다 큰지 체크
            if(boardVO.getFileId() != null && boardVO.getFileId() > 0) { 
                // DB에서 파일 상세 정보들을 가져와서 FileTbVO에 담아줍니다.
            	List<FileDetailVO> fileList = boardMapper.selectFileList(String.valueOf(boardVO.getFileId()));
                
                FileTbVO fileTbVO = new FileTbVO();
                fileTbVO.setFileId(boardVO.getFileId());
                fileTbVO.setFileDetailVOList(fileList);
                
                boardVO.setFileTbVO(fileTbVO);
            }
        }
        log.info("조립 완료된 boardVO: {}", boardVO);
        return boardVO;
    }

    // 기존 selectBoardDetail(int bbsNo)은 유지하거나 
    // 위 메서드를 호출하도록 수정해서 코드 중복을 방지하세요.
    @Override
    public BoardVO selectBoardDetail(int bbsNo) {
        return this.selectBoardDetailAll(bbsNo);
    }

	// 3. 부서별 게시판 목록 조회 (검색 및 페이징 파라미터 포함)
	@Override
	public List<BoardVO> selectBoardList(Map<String, Object> map) {
		return this.boardMapper.selectBoardList(map);
	}

	// 4. 전체 부서별 게시판 행의 수 조회 (페이징 처리를 위함)
	@Override
	public int selectBoardCount(Map<String, Object> map) {
		return this.boardMapper.selectBoardCount(map);
	}

	// 5. 부서별 게시판 수정 실행 (파일 마이그레이션 로직 포함)
	@Transactional
	@Override
	public int updateBoard(BoardVO boardVO) {
	    // [추가 로직] 게시글 수정 시 신고 누적 횟수를 0으로 초기화
	    // 작성자가 내용을 수정했으므로 다시 클린한 상태로 만들어줍니다.
	    int bbsNo = boardVO.getBbsNo();
	    this.complaintMapper.resetReportCount(bbsNo);
	    log.info("### 게시글 수정 감지: BBS_NO {}번의 신고 누적 횟수가 초기화되었습니다.", bbsNo);

	    // --- 여기서부터 기존 로직 유지 ---
	    BoardVO existingBoard = this.boardMapper.selectBoardDetail(boardVO.getBbsNo());
	    long oldFileId = (existingBoard != null && existingBoard.getFileId() != null) ? existingBoard.getFileId() : 0L;

	    if(boardVO.getDelFileDtlIds() != null && boardVO.getDelFileDtlIds().length > 0) {
	        for(String dtlId : boardVO.getDelFileDtlIds()) {
	            this.boardMapper.deleteFileDetail(dtlId);
	        }
	    }

	    long newFileId = handleFileUpload(boardVO, 0L); 

	    if (newFileId > 0 && oldFileId > 0 && newFileId != oldFileId) {
	        Map<String, Object> map = new HashMap<>();
	        map.put("oldFileId", oldFileId);
	        map.put("newFileId", newFileId);
	        this.boardMapper.migrateFiles(map);
	        boardVO.setFileId(newFileId);
	    } else if (newFileId > 0) {
	        boardVO.setFileId(newFileId);
	    } else {
	        boardVO.setFileId(oldFileId);
	    }

	    return this.boardMapper.updateBoard(boardVO);
	}

	// 6. 부서별 게시판 삭제 실행
	@Override
	public int deleteBoard(int bbsNo) {
		return this.boardMapper.deleteBoard(bbsNo);
	}

	// 7. 조회수 증가
	@Override
	public int incrementViewCount(int bbsNo) {
		return this.boardMapper.incrementViewCount(bbsNo);
	}

	/**
	 * 8. [통합 비즈니스 로직] 게시물 액션 처리
	 * 좋아요/싫어요/추천 버튼 클릭 시 장부 기록과 카운트 증감을 한 번에 처리하네.
	 */
	@Transactional
	@Override
	public Map<String, Object> processBoardAction(int bbsNo, int empId, String actionType) {
		Map<String, Object> result = new HashMap<>();
		Map<String, Object> param = new HashMap<>();
		param.put("bbsNo", bbsNo);
		param.put("empId", empId);
		param.put("actionType", actionType);

		// 본인 글 여부 확인 (작성자 사번 조회)
		int writerId = this.boardMapper.getBoardWriterId(bbsNo);
		if (writerId == empId) {
			result.put("resultCode", -1); // 본인 글 액션 불가
			return result;
		}

		int count = this.boardMapper.checkUserAction(param);

		if (count == 0) {
			// 처음 클릭: 장부 기록 + 카운트 증가
			this.boardMapper.insertUserAction(param);
			if ("LIKE".equals(actionType)) this.boardMapper.incrementLikeCount(bbsNo);
			else if ("DISLIKE".equals(actionType)) this.boardMapper.incrementDislikeCount(bbsNo);
			else if ("RECOM".equals(actionType)) this.boardMapper.incrementRecomCount(bbsNo);
			result.put("resultCode", 1); // 등록 성공
		} else {
			// 다시 클릭: 장부 삭제 + 카운트 감소
			this.boardMapper.deleteUserAction(param);
			if ("LIKE".equals(actionType)) this.boardMapper.decrementLikeCount(bbsNo);
			else if ("DISLIKE".equals(actionType)) this.boardMapper.decrementDislikeCount(bbsNo);
			else if ("RECOM".equals(actionType)) this.boardMapper.decrementRecomCount(bbsNo);
			result.put("resultCode", 2); // 취소 성공
		}

		// 최신 게시글 정보를 담아 반환 (화면 실시간 반영용)
		BoardVO updatedBoard = new BoardVO();
		updatedBoard.setBbsNo(bbsNo);
		result.put("board", this.boardMapper.selectBoardDetail(updatedBoard.getBbsNo()));
		
		return result;
	}

	// 9. 좋아요 카운트 증가
	@Override 
	public int incrementLikeCount(int bbsNo) {
		return boardMapper.incrementLikeCount(bbsNo); 
	}
	
	// 10. 좋아요 카운트 감소
	@Override 
	public int decrementLikeCount(int bbsNo) {
		return boardMapper.decrementLikeCount(bbsNo); 
	}
	
	// 11. 싫어요 카운트 증가
	@Override 
	public int incrementDislikeCount(int bbsNo) {
		return boardMapper.incrementDislikeCount(bbsNo); 
	}
	
	// 12. 싫어요 카운트 감소
	@Override
	public int decrementDislikeCount(int bbsNo) {
		return boardMapper.decrementDislikeCount(bbsNo); 
	}
	
	// 13. 추천 카운트 증가
	@Override 
	public int incrementRecomCount(int bbsNo) {
		return boardMapper.incrementRecomCount(bbsNo); 
	}
	
	// 14. 추천 카운트 감소
	@Override 
	public int decrementRecomCount(int bbsNo) {
		return boardMapper.decrementRecomCount(bbsNo); 
	}
	
	// 15. 사용자가 해당 게시물에 특정 액션(LIKE/DISLIKE/RECOM)을 이미 했는지 확인
	@Override 
	public int checkUserAction(Map<String, Object> map) {
		return this.boardMapper.checkUserAction(map); 
	}

	// 16. 게시물 반응 장부(BOARD_ACTIONS)에 기록 추가
	@Override
	public int insertUserAction(Map<String, Object> map) {
		return this.boardMapper.insertUserAction(map); 
	}

	// 17. 게시물 반응 장부(BOARD_ACTIONS)에서 기록 삭제
	@Override 
	public int deleteUserAction(Map<String, Object> map) {
		return this.boardMapper.deleteUserAction(map); 
	}

	// 18. 사용자가 이 게시글에 남긴 모든 반응 리스트 조회
	@Override 
	public List<String> selectUserActionList(Map<String, Object> map) {
		return this.boardMapper.selectUserActionList(map); 
	}

	@Override
    public List<CommentVO> selectCommentList(int bbsNo) {
        // Mapper를 통해 DB에서 댓글 리스트를 가져옵니다.
        return this.boardMapper.selectCommentList(bbsNo);
    }

    @Override
    public List<FileDetailVO> selectFileList(Long fileId) {
        // Mapper를 통해 DB에서 파일 상세 리스트를 가져옵니다.
        // 만약 Mapper 인터페이스가 String을 받는다면 String.valueOf(fileId)를 사용하세요.
        return this.boardMapper.selectFileList(String.valueOf(fileId));
    }
}