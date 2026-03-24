package kr.or.ddit.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.vo.DataVO;

public interface DataService {
	
	// 1. 자료실 등록 (첨부파일 처리 로직 포함)
	public int insertData(DataVO dataVO, MultipartFile[] uploadFile);
	
	// 2. 자료실 상세 조회 (조회수 증가 로직 포함)
	public DataVO selectDataDetail(DataVO dataVO);
	
	// 3. 자료실 목록 조회 (검색 및 페이징 파라미터 포함)
	public List<DataVO> selectDataList(Map<String, Object> map);
	
	// 4. 전체 자료실 행의 수 조회 (페이징 처리를 위함)
	public int selectDataCount(Map<String, Object>map);
	
	// 5. 자료실 수정 실행
	public int updateData(DataVO dataVO);
	
	// 6. 자료실 삭제 실행
	public int deleteData(int dataNo);
	
	// 7. 조회수 증가 (단독 호출용)
	public int incrementViewCount(int dataNo);
}
