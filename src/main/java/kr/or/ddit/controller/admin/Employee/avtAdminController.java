package kr.or.ddit.controller.admin.Employee;

import kr.or.ddit.service.avatarService;
import kr.or.ddit.vo.AvatarVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;

@Slf4j
@RequestMapping("/admin/avatar")
@CrossOrigin(origins = "http://localhost:5173")
@RestController
public class avtAdminController {

    @Value("${file.avtFolder}")
    private String avtFolder;

    @Autowired
    avatarService avatarService;


    // 아바타 사진
    @GetMapping("/displayavt")
    @ResponseBody
    public byte[] display(@RequestParam("fileName") String fileName) {
        try {
            // 1. 한글 파일명 디코딩 (필수!)
            String decodedName = java.net.URLDecoder.decode(fileName, "UTF-8");

            // 2. 경로 조합 (슬래시 누락 방지)
            String path = avtFolder + (avtFolder.endsWith("/") ? "" : "/") + decodedName;

            log.info("이미지 로드 경로: {}", path);

            // 3. 파일을 바이트 배열로 읽어서 전송
            // 이렇게 하면 스프링이 자동으로 적절한 Content-Type을 시도합니다.
            return java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(path));

        } catch (Exception e) {
            log.error("이미지 표시 실패", e);
            return null; // 에러 시 엑박 방지를 위해 null 리턴
        }
    }


    // (관리자) 아바타 수정
    @ResponseBody
    @PostMapping("/update")
    public String update(@ModelAttribute AvatarVO vo) {
        log.info("누가 왔늬 ? 아바타 : {}", vo);

        MultipartFile avtimg = vo.getAvtimg();

        String avtFileName = "";

        // 파일 처리하기
        if(avtimg != null && !avtimg.isEmpty()) {
            avtFileName = avtimg.getOriginalFilename();

            // 저장되는 곳
            File saveFile = new File(avtFolder, avtFileName);

            try {
                avtimg.transferTo(saveFile);
                vo.setAvtSaveNm(avtFileName);
            } catch (IllegalStateException | IOException e) {
                log.error(e.getMessage());
            }
        }

        log.info("보내기 전 확인 : vo : {}", vo);
        int result = this.avatarService.update(vo);

        if(result > 0) {
            return "success";
        } else {
            return "fail";
        }
    }

    // (관리자) 아바타 등록
    @ResponseBody
    @PostMapping("/insert")
    public String insert(@ModelAttribute AvatarVO vo) {
        log.info("누가 왔늬 ? 아바타 : {}", vo);

        MultipartFile avtimg = vo.getAvtimg();

        String avtFileName = "";

        // 파일 처리하기
        if(avtimg != null && !avtimg.isEmpty()) {
            avtFileName = avtimg.getOriginalFilename();

            // 저장되는 곳
            File saveFile = new File(avtFolder, avtFileName);

            try {
                avtimg.transferTo(saveFile);
                vo.setAvtSaveNm(avtFileName);
            } catch (IllegalStateException | IOException e) {
                log.error(e.getMessage());
            }
        }

        log.info("보내기 전 확인 : vo : {}", vo);
        int result = this.avatarService.insert(vo);

        if(result > 0) {
            return "success";
        } else {
            return "fail";
        }
    }

    // (관리자) 아바타 삭제
    @ResponseBody
    @PatchMapping("/delete")
    public String delete(@RequestBody AvatarVO vo) {
        log.info("누가 왔늬 ? 아바타 : {}", vo);

        int result = this.avatarService.delete(vo);

        if(result > 0) {
            return "success";
        } else {
            return "fail";
        }
    }

    // (관리자) 아바타 List 불러오기
    @GetMapping("/getavtlist")
    public List<AvatarVO> getavtlist (@RequestParam(required = false) String cate,
                                      @RequestParam(required = false) String sortSelect) {
        log.info("sortSelect : {}", sortSelect);
        log.info("cate : {}", cate);

        List<AvatarVO> avtlist = this.avatarService.getallavtlist(sortSelect,cate);

        return avtlist;
    }
}

