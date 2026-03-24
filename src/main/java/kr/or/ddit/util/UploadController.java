package kr.or.ddit.util;

import kr.or.ddit.mapper.ItemMapper;
import kr.or.ddit.vo.FileDetailVO;
import kr.or.ddit.vo.FileTbVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import java.util.UUID;

@Controller
@Slf4j
public class UploadController {
    @Autowired
    ItemMapper itemMapper;
    //public int insertFileGroup(FileGroupVO fileGroupVO);
    //public int insertFileDetail(FileDetailVO fileDetailVO);
    @Value("${file.uploadFolder}")
    String uploadFolder;
    String pictureUrl = "";
    //아래 파일 업로드
    //------------------------------------------------------------------------------------------------------------------
    public long multiFileUpload(MultipartFile[] multipartFiles, FileTbVO fileGroupVO) {
        log.info("multiFileUpload->multiFiles : {} ", multipartFiles);
        Long fileGroupNo = 0L;
        int result = 0;

        //일단 파일 그룹 테이블에  INSERT를 함.
        //EMP_ID 와 FILE_KND_NM정보를 가지고 있어야 함.
        result += this.itemMapper.insertFileGroup(fileGroupVO);

        fileGroupNo = fileGroupVO.getFileId();
        for (MultipartFile multipartFile : multipartFiles) {
            File uploadPath = new File(this.uploadFolder, getFolder());
            if (!uploadPath.exists()) {
                uploadPath.mkdirs();
            }
            String uploadFileName = multipartFile.getOriginalFilename();
            UUID uuid = UUID.randomUUID();
            uploadFileName = uuid + "_" + uploadFileName;
            File saveFile = new File(uploadPath, uploadFileName);
            try {multipartFile.transferTo(saveFile);            } catch (IllegalStateException | IOException e) {e.printStackTrace();}
            pictureUrl =
                    "/" + getFolder().replace("\\", "/") + "/"
                            + uploadFileName;

            FileDetailVO fileDetailVO = new FileDetailVO();

            fileDetailVO.setFileId(fileGroupNo);
            fileDetailVO.setFileDtlONm(multipartFile.getOriginalFilename());
            fileDetailVO.setFileDtlSaveNm(uploadFileName);//UUID + "_" + 파일명
            fileDetailVO.setFileDtlPath(pictureUrl);// /2025/02/21/sdaflkfdsaj_개똥이.jpg
            fileDetailVO.setFileDtlExt(
                    multipartFile.getOriginalFilename().substring(multipartFile.getOriginalFilename().lastIndexOf(".")+1)
            );//jpg(확장자)
            fileDetailVO.setEmpId(fileGroupVO.getEmpId());
            //FILE_DETAIL 테이블에 insert
            result += this.itemMapper.insertFileDetail(fileDetailVO);
        }
        return fileGroupNo;
    }
    //------------------------------------------------------------------------------------------------------------------
//이미지 출력 메서드
    public String imageToBase64(String savePath) throws Exception {
        String base64Img = "";

        log.info("imageToBase64->savePath : " + savePath);

        File f = new File(savePath);
        if (f.exists() && f.isFile() && f.length() > 0) {
            byte[] bt = new byte[(int) f.length()];
            try (FileInputStream fis = new FileInputStream(f)) {
                fis.read(bt);
                /*
                자바 21 이상 버젼에서는 기본 api로 해결 가능해서 지금 문법에서 오류난다고합니다!
                외부라이브러리 base64로 안끌어와도된다고합니다
                 */
                // Using java.util.Base64
                base64Img = Base64.getEncoder().encodeToString(bt);
                log.info("Base64 Encoded Image: " + base64Img);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return base64Img;
    }
    //------------------------------------------------------------------------------------------------------------------
    //연 월 일 폴더 생성 메서드
    public String getFolder() {
        //2025-02-21 형식(format) 지정
        //간단 날짜 형식
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        //날짜 객체 생성(java.util 패키지)
        Date date = new Date();
        String str = sdf.format(date);
        //str : 2026-01-13
        log.info("getFolder->str : " + str);

        // '\\' : 윈도우 파일 세퍼레이터
        //str : 2025-02-21 -> 2025\\02\\21
        log.info("getFolder-> (1) : " + str.replace("-", "\\"));
        log.info("getFolder-> (2) : " + str.replace("-", File.separator));

        return str.replace("-", File.separator);
    }
    
    /**
     * 파일 다운로드 (ResponseEntity 활용)
     */
    @GetMapping("/download") 
    public ResponseEntity<Resource> downloadFile(@RequestParam("fileDtlId") Long fileDtlId) { 
        log.info("📢 다운로드 요청 fileDtlId : {}", fileDtlId);
        
        // 1. [기존 로직 유지] DB에서 상세 ID(PK)로 먼저 조회합니다.
        FileDetailVO detail = this.itemMapper.getFileDetail(fileDtlId);
        
        // 🌟 [추가 로직] 상세 ID로 검색했을 때 결과가 없다면? (채팅방 그룹 ID로 간주하고 재조회)
        if (detail == null) {
            log.warn("⚠️ 상세 PK로 조회 결과 없음. 그룹 ID로 재조회를 시도합니다. ID: {}", fileDtlId);
            
            // 새로 Mapper.xml에 추가하신 그룹 ID 조회 메서드를 호출합니다.
            // (메서드명이 getFileDetailByFileId 인지 getFileDetailByGroupId 인지 자바 인터페이스 정의에 맞게 맞춰주세요!)
            detail = this.itemMapper.getFileDetailByGroupId(fileDtlId); 
        }
        
        // 2. [두 번 다 조회했는데도 없는 경우]
        if (detail == null) {
            log.error("❌ 최종 파일 정보를 DB에서 찾을 수 없습니다. ID: {}", fileDtlId);
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        // 3. [기존 로직 유지] 파일 객체 생성
        File targetFile = new File(this.uploadFolder, detail.getFileDtlPath());
        Resource resource = new FileSystemResource(targetFile);

        // 4. [기존 로직 유지] 실제 파일 존재 여부 확인
        if (!resource.exists()) {
            log.error("❌ 서버 경로에 실제 파일이 존재하지 않습니다: {}", targetFile.getAbsolutePath());
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        // 5. [기존 로직 유지] 헤더 설정 (한글 깨짐 방지 및 다운로드 설정)
        HttpHeaders headers = new HttpHeaders();
        try {
            String originalName = detail.getFileDtlONm();
            String downloadName = UriUtils.encode(originalName, StandardCharsets.UTF_8);
            
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + downloadName + "\"");
            headers.add(HttpHeaders.CONTENT_TYPE, "application/octet-stream");
        } catch (Exception e) {
            log.error("❌ 파일명 인코딩 에러: {}", e.getMessage());
        }
        
        return new ResponseEntity<>(resource, headers, HttpStatus.OK);
    }
}
