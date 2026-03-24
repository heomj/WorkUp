package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.vo.DataVO;

@Mapper
public interface DataMapper {
	
	// 자료실 등록(dataNo 시퀀스 처리)
	public int insertData(DataVO dataVO);
	
	// 자료실 상세 조회 (파일 조인 포함)
	public DataVO selectDataDetail(DataVO dataVO);
	
	// 자료실 목록 조회 (페이징/검색)
	public List<DataVO> selectDataList(Map<String, Object> map);
	
	// 전체 행의 수 (검색 반영)
	public int selectDataCount(Map<String, Object>map);
	
	// 자료실 수정
	public int updateData(DataVO dataVO);
	
	// 자료실 삭제 (물리 사제 또는 DATA_DEL_YN)
	public int deleteData(int dataNo);
	
	// 조회수 증가
	public int incrementViewCount(int dataNo);
	
	// 기존 첨부파일 삭제
	public int deleteFileDetail(String fileDtlId);
	
	// 기존 파일들을 새로운 FILE_ID 그룹으로 옮기는 메서드
	public int migrateFiles(Map<String, Object> map);
}
