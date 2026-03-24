package kr.or.ddit.controller.admin.board;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.service.DataService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.DataVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/admin/data")
public class DataAdminController {

    @Autowired
    private DataService dataService;

    @Autowired
    private UploadController uploadController;

    /**
     * 1. 관리자 자료실 목록 조회
     */
    @PostMapping("/list")
    public ArticlePage<DataVO> adminList(@RequestBody DataVO dataVO) {
        Map<String, Object> map = new HashMap<>();
        int currentPage = (dataVO.getCurrentPage() <= 0) ? 1 : dataVO.getCurrentPage();
        int size = 10;
        
        map.put("currentPage", currentPage);
        map.put("keyword", dataVO.getKeyword());
        map.put("mode", dataVO.getMode());
        map.put("size", size);
        
        int total = this.dataService.selectDataCount(map);
        List<DataVO> dataList = this.dataService.selectDataList(map);

        return new ArticlePage<>(total, currentPage, size, dataVO.getKeyword(), dataList);
    }

    /**
     * 2. 자료 상세 조회
     */
    @GetMapping("/detail/{dataNo}")
    public DataVO adminDetail(@PathVariable("dataNo") int dataNo) {
        log.info("관리자 자료 상세조회 dataNo: {}", dataNo);
        DataVO dataVO = new DataVO();
        dataVO.setDataNo(dataNo);
        
        return this.dataService.selectDataDetail(dataVO);
    }

    /**
     * 3. 자료 등록 (인터페이스 규격: DataVO, MultipartFile[] 에 맞춤)
     */
    @PostMapping("/create")
    public Map<String, Object> adminCreate(DataVO dataVO, 
                                         @RequestParam(value="uploadFiles", required=false) MultipartFile[] uploadFiles,
                                         Authentication auth) {
        Map<String, Object> response = new HashMap<>();

        if (auth == null || !(auth.getPrincipal() instanceof CustomUser)) {
            response.put("result", "fail");
            response.put("message", "세션이 만료되었습니다.");
            return response;
        }

        CustomUser customUser = (CustomUser) auth.getPrincipal();
        dataVO.setEmpId(customUser.getEmpVO().getEmpId());
        
        // 기본 부서 코드 설정
        if (dataVO.getDataDeptCd() == 0) {
            dataVO.setDataDeptCd(customUser.getEmpVO().getDeptCd());
        }

        try {
            // ⭐️ 핵심: 인터페이스 선언대로 2개의 파라미터를 정확히 전달합니다.
            // 이렇게 하면 'insertData' 부분의 에러 밑줄이 사라집니다.
            int result = this.dataService.insertData(dataVO, uploadFiles);
            
            if (result > 0) {
                response.put("result", "success");
                response.put("dataNo", dataVO.getDataNo());
            } else {
                response.put("result", "fail");
            }
        } catch (Exception e) {
            log.error("자료 등록 중 오류 발생: ", e);
            response.put("result", "fail");
            response.put("message", e.getMessage());
        }

        return response;
    }

    /**
     * 4. 자료 수정 (인터페이스 규격: DataVO 에 맞춤)
     */
    @PostMapping("/update")
    public Map<String, Object> adminUpdate(
            DataVO dataVO,
            @RequestParam(value="delFileDtlIds", required=false) String[] delFileDtlIds, 
            @RequestParam(value="uploadFiles", required=false) MultipartFile[] uploadFiles,
            Authentication auth) {
        
        log.info("관리자 자료 수정 요청 dataNo: {}", dataVO.getDataNo());
        Map<String, Object> response = new HashMap<>();

        if (auth == null) {
            response.put("result", "fail");
            return response;
        }

        // 1. 새로 추가된 파일이 있다면 VO에 세팅 (ServiceImpl의 handleFileUpload에서 꺼내 씀)
        if(uploadFiles != null && uploadFiles.length > 0 && !uploadFiles[0].isEmpty()) {
            dataVO.setUploadFiles(uploadFiles);
        }

        // 2. 삭제할 파일 목록 세팅
        dataVO.setDelFileDtlIds(delFileDtlIds);

        try {
            // 인터페이스 규격대로 dataVO 하나만 전달
            int result = this.dataService.updateData(dataVO);
            
            if (result > 0) {
                response.put("result", "success");
            } else {
                response.put("result", "fail");
            }
        } catch (Exception e) {
            log.error("자료 수정 중 오류 발생: ", e);
            response.put("result", "fail");
        }

        return response;
    }

    /**
     * 5. 자료 삭제
     */
    @DeleteMapping("/delete/{dataNo}")
    public Map<String, Object> adminDelete(@PathVariable("dataNo") int dataNo) {
        int result = this.dataService.deleteData(dataNo);
        Map<String, Object> response = new HashMap<>();
        response.put("result", result > 0 ? "success" : "fail");
        return response;
    }

    /**
     * 6. 파일 다운로드
     */
    @GetMapping("/download")
    public ResponseEntity<Resource> downloadFile(@RequestParam("fileDtlId") Long fileDtlId) {
        return uploadController.downloadFile(fileDtlId);
    }
}