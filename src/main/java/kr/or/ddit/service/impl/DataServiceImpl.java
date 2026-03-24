package kr.or.ddit.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.mapper.DataMapper;
import kr.or.ddit.service.DataService;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.DataVO;
import kr.or.ddit.vo.FileTbVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class DataServiceImpl implements DataService {
	
	@Autowired
	private UploadController uploadController;
	
	@Autowired
	private DataMapper dataMapper;
	
	// 파일 처리 공통 메서드
	private long handleFileUpload(DataVO dataVO, long existingFileId) {
	    MultipartFile[] multipartFiles = dataVO.getUploadFiles(); 
	    
	    // 새로 추가할 파일이 있는 경우
	    if(multipartFiles != null && multipartFiles.length > 0 &&
	       !multipartFiles[0].getOriginalFilename().isEmpty()) {
	        
	        FileTbVO fileGroupVO = new FileTbVO();
	        fileGroupVO.setEmpId(dataVO.getEmpId()); 
	        fileGroupVO.setFileStts("자료실"); 
	        
	        // [핵심] 기존 FILE_ID가 있다면 그룹 VO에 세팅합니다.
	        // uploadController가 이 ID를 보고 "아, 새로 만들지 말고 여기(FILE_DETAIL)에 인서트해!"라고 판단해야 합니다.
	        if (existingFileId > 0) {
	            fileGroupVO.setFileId(existingFileId);
	        }
	        
	        Long resultFileId = this.uploadController.multiFileUpload(multipartFiles, fileGroupVO);
	        return (resultFileId != null) ? resultFileId : existingFileId;
	    }
	    
	    // 추가할 파일이 없으면 기존 ID를 그대로 반환
	    return existingFileId; 
	}
	
	@Transactional
	@Override
	public int insertData(DataVO dataVO, MultipartFile[] uploadFile) {
	    if (uploadFile != null && uploadFile.length > 0 && !uploadFile[0].isEmpty()) {
	        dataVO.setUploadFiles(uploadFile);
	        
	        // handleFileUpload 메서드가 파라미터를 2개 받도록 수정되었으므로,
	        // 신규 등록 시에는 기존 파일 ID가 없다는 의미로 0L을 함께 보냅니다.
	        long fileId = handleFileUpload(dataVO, 0L); 
	        
	        if(fileId > 0) {
	            dataVO.setFileId(fileId);
	        }
	    } else {
	        dataVO.setFileId(0L); 
	    }
	    
	    log.info("insert 직전 fileId 체크: {}", dataVO.getFileId());
	    return this.dataMapper.insertData(dataVO);
	}

	@Override
	public DataVO selectDataDetail(DataVO dataVO) {
		return this.dataMapper.selectDataDetail(dataVO);
	}

	@Override
	public List<DataVO> selectDataList(Map<String, Object> map) {
		return this.dataMapper.selectDataList(map);
	}

	@Override
	public int selectDataCount(Map<String, Object> map) {
		return this.dataMapper.selectDataCount(map);
	}
	
	@Transactional
	@Override
	public int updateData(DataVO dataVO) {
	    // 1. 기존 데이터 조회
	    DataVO existingData = this.dataMapper.selectDataDetail(dataVO);
	    long oldFileId = (existingData != null && existingData.getFileId() != null) ? existingData.getFileId() : 0L;

	    // 2. 수동 삭제 처리
	    if(dataVO.getDelFileDtlIds() != null && dataVO.getDelFileDtlIds().length > 0) {
	        for(String dtlId : dataVO.getDelFileDtlIds()) {
	            this.dataMapper.deleteFileDetail(dtlId);
	        }
	    }

	    // 3. 신규 파일 업로드 (기존 ID를 0L로 주어 새로운 그룹 생성)
	    long newFileId = handleFileUpload(dataVO, 0L); 

	    // 4. [중요] 기존 파일과 신규 파일 합치기
	    if (newFileId > 0 && oldFileId > 0 && newFileId != oldFileId) {
	        // Map 생성 (java.util 패키지)
	        Map<String, Object> map = new HashMap<>();
	        map.put("oldFileId", oldFileId);
	        map.put("newFileId", newFileId);
	        
	        // 여기서 에러 밑줄이 사라질 겁니다!
	        this.dataMapper.migrateFiles(map);
	        
	        // 최종적으로 게시글은 모든 파일이 모인 newFileId를 가집니다.
	        dataVO.setFileId(newFileId);
	    } 
	    else if (newFileId > 0) {
	        dataVO.setFileId(newFileId);
	    } 
	    else {
	        dataVO.setFileId(oldFileId);
	    }

	    // 5. 게시글 수정 실행
	    return this.dataMapper.updateData(dataVO);
	}
	
	@Transactional
	@Override
	public int deleteData(int dataNo) {
		return this.dataMapper.deleteData(dataNo);
	}

	@Override
	public int incrementViewCount(int dataNo) {
		return this.dataMapper.incrementViewCount(dataNo);
	}

}
