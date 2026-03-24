package kr.or.ddit.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import kr.or.ddit.mapper.NoticeMapper;
import kr.or.ddit.service.NoticeService;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.FileTbVO;
import kr.or.ddit.vo.NoticeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class NoticeServiceImpl implements NoticeService {

    @Autowired
    private UploadController uploadController;
    
    @Autowired
    private NoticeMapper noticeMapper;
    
    /**
     * 파일 업로드 및 FILE_ID 반환 공통 로직
     */
    private long handleFileUpload(NoticeVO noticeVO) { 
        MultipartFile[] multipartFiles = noticeVO.getUploadFiles(); 
        
        if (multipartFiles != null && multipartFiles.length > 0) {
            boolean hasFile = false;
            for (MultipartFile file : multipartFiles) {
                if (file != null && !file.isEmpty()) {
                    hasFile = true;
                    break;
                }
            }

            if (hasFile) {
                FileTbVO fileGroupVO = new FileTbVO();
                fileGroupVO.setEmpId(noticeVO.getEmpId()); 
                fileGroupVO.setFileStts("공지사항"); 
                
                // uploadController가 이미 Long을 반환하므로 그대로 사용
                Long fileId = this.uploadController.multiFileUpload(multipartFiles, fileGroupVO);
                log.info("생성된 파일 그룹 ID: {}", fileId);
                
                // 2. intValue()를 제거하고 Long 값을 그대로 반환 (null이면 0L)
                return (fileId != null) ? fileId : 0L;
            }
        }
        return 0L;
    }

    @Transactional
    @Override
    public int insertNotice(NoticeVO noticeVO) {
        MultipartFile[] uploadFiles = noticeVO.getUploadFiles();
        
        if (uploadFiles != null && uploadFiles.length > 0 && !uploadFiles[0].isEmpty()) {
            log.info("파일 발견! 업로드 처리를 시작합니다.");
            
            // ⭐️ 여기서도 long으로 받습니다.
            long fileId = handleFileUpload(noticeVO); 
            
            if(fileId > 0) {
                noticeVO.setFileId(fileId);
                log.info("생성된 fileId를 VO에 세팅함: {}", fileId);
            }
        } else {
            noticeVO.setFileId(0L); 
        }
        
        return noticeMapper.insertNotice(noticeVO);
    }

    @Transactional
    @Override
    public int updateNotice(NoticeVO noticeVO) {
        // 1. 기존 게시글 정보를 조회하여 현재 DB에 저장된 fileId(oldFileId)를 가져옵니다.
        NoticeVO existingNotice = this.noticeMapper.selectNoticeDetail(noticeVO.getNtcNo());
        long oldFileId = (existingNotice != null) ? existingNotice.getFileId() : 0L;

        // 2. [선택] 만약 리액트에서 '삭제' 버튼을 누른 파일 ID 목록(delFileDtlIds)을 보낸다면 삭제 처리
        if(noticeVO.getDelFileDtlIds() != null && noticeVO.getDelFileDtlIds().length > 0) {
            for(String dtlId : noticeVO.getDelFileDtlIds()) {
                // Mapper에 상세 파일 삭제 메서드가 있어야 합니다.
                // this.noticeMapper.deleteFileDetail(dtlId); 
            }
        }

        // 3. 신규 추가된 파일 업로드 (새로운 그룹 ID 생성)
        // 기존 handleFileUpload 메서드를 호출하여 신규 파일이 있으면 새 fileId를 받습니다.
        long newFileId = handleFileUpload(noticeVO); 

        // 4. ⭐️ [핵심 로직] 기존 파일과 신규 파일 합치기
        if (newFileId > 0 && oldFileId > 0 && newFileId != oldFileId) {
            // 예제 코드의 migrateFiles 로직 사용
            Map<String, Object> map = new HashMap<>();
            map.put("oldFileId", oldFileId); // 기존에 있던 파일들
            map.put("newFileId", newFileId); // 방금 업로드된 파일들
            
            // 기존 파일들의 FILE_ID를 newFileId로 전부 변경하는 SQL 실행
            this.noticeMapper.migrateFiles(map);
            
            // 최종적으로 게시글은 모든 파일이 모인 newFileId를 가집니다.
            noticeVO.setFileId(newFileId);
        } 
        else if (newFileId > 0) {
            // 새로만 추가된 경우
            noticeVO.setFileId(newFileId);
        } 
        else {
            // 추가된 파일이 없으면 기존 ID 유지
            noticeVO.setFileId(oldFileId);
        }

        // 5. 공지사항 테이블(NOTICE) 업데이트
        return this.noticeMapper.updateNotice(noticeVO);
    }

    @Override
    public NoticeVO selectNoticeDetail(NoticeVO noticeVO) {
        // resultMap="noticeMap"에 의해 NOTICE의 FILE_ID와 연관된 FILE_DETAIL 목록을 자동으로 가져옴
        return noticeMapper.selectNoticeDetail(noticeVO.getNtcNo());
    }

    @Override
    public List<NoticeVO> selectNoticeList(Map<String, Object> map) {
        return this.noticeMapper.selectNoticeList(map);
    }

    @Override
    public int selectNoticeCount(Map<String, Object> map) {
        return this.noticeMapper.selectNoticeCount(map);
    }

    @Transactional
    @Override
    public int deleteNotice(int ntcNo) {
        return this.noticeMapper.deleteNotice(ntcNo);
    }

    @Override
    public void incrementViewCount(int ntcNo) {
        this.noticeMapper.incrementViewCount(ntcNo);
    }
    
    @Override
    public NoticeVO selectLatestUrgentNotice() {
        return this.noticeMapper.selectLatestUrgentNotice();
    }
}