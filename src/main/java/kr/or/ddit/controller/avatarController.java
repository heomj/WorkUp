package kr.or.ddit.controller;

import kr.or.ddit.service.avatarService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.vo.AvatarVO;
import kr.or.ddit.vo.EmpAvtVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RequestMapping("/avatar")
@Controller
public class avatarController {

    @Autowired
    avatarService avtService;

    @Value("${file.avtFolder}")
    private String avtFolder;

    // 아바타 사진 띄우기
    @GetMapping("/displayAvt")
    @ResponseBody
    public Resource display(@RequestParam("fileName") String fileName) {
        return new FileSystemResource(avtFolder + fileName);
    }

    // 아바타 구매하기
    @ResponseBody
    @PostMapping("/buyavt")
    public String butavt(@RequestParam("avtNo") int avtNo,
                         @RequestParam("avtPrice") int avtPrice,
                         Authentication auth){
        log.info("avtNo값 : {}",avtNo);

        EmpAvtVO vo = new EmpAvtVO();

        CustomUser customUser = (CustomUser)auth.getPrincipal();
        vo.setEmpId(customUser.getEmpVO().getEmpId());
        vo.setAvtNo(avtNo);

       int result = this.avtService.butavt(vo);

        if(result == 1) {
            int beforMlg =  customUser.getEmpVO().getEmpMlg();
            int resultMlg = beforMlg - avtPrice;
            customUser.getEmpVO().setEmpMlg(resultMlg);

            return "success";
        }
        else if(result == 2) {
            return "having";
        }
        else {

            return "fail";
        }
    }

    // 내 아바타 삭제하기
    @ResponseBody
    @PatchMapping("/deleteavt/{avtNo}")
    public int deleteavt(@PathVariable int avtNo, Authentication auth){

        log.info("아바타 번호 : {}", avtNo);

        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmpAvtVO empAvtVO = new EmpAvtVO();
        empAvtVO.setEmpId(customUser.getEmpVO().getEmpId());
        empAvtVO.setAvtNo(avtNo);

        int result = this.avtService.deleteavt(empAvtVO);

        return result;
    }

    // 아바타 착용하기
    @ResponseBody
    @PatchMapping("/wearavt")
    public int wearavt(@RequestBody AvatarVO vo,
                       Authentication auth){

        log.info("아바타 : {}", vo);

        CustomUser customUser = (CustomUser)auth.getPrincipal();
        EmpAvtVO empAvtVO = new EmpAvtVO();
        empAvtVO.setEmpId(customUser.getEmpVO().getEmpId());
        empAvtVO.setAvtNo(vo.getAvtNo());

        int result = this.avtService.wearavt(empAvtVO);
        log.info("empAvtVO : {}",empAvtVO);
        if(result > 0) {
            customUser.getEmpVO().setAvtSaveNm(vo.getAvtSaveNm());
        }

        return result;
    }
}
