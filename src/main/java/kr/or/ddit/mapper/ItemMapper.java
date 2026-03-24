package kr.or.ddit.mapper;

import kr.or.ddit.vo.FileDetailVO;
import kr.or.ddit.vo.FileTbVO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ItemMapper {
	//1. FILE_GROUP 테이블에 insert(1회 실행)
	//실행전 fileGroupVO{fileGroupNo=0,fileRegdate=null)
	//실행후 fileGroupVO{fileGroupNo=20250226001,fileRegdate=null) 왜냐하면 selectKey에 의해서..
    int insertFileGroup(FileTbVO fileGroupVO);

	//FILE_DETAIL 테이블에 insert
    int insertFileDetail(FileDetailVO fileDetailVO);
    
    // [추가] 파일 상세 정보 한 건 조회 (다운로드용)
    public FileDetailVO getFileDetail(Long fileDtlId);
    
    FileDetailVO getFileDetailByGroupId(Long fileId);
}



