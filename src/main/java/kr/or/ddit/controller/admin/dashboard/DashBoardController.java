package kr.or.ddit.controller.admin.dashboard;


import kr.or.ddit.service.DashBdAdminService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RequestMapping("/admin/dashbd")
@CrossOrigin(origins = "http://localhost:5173")
@RestController
public class DashBoardController {

    @Autowired
    DashBdAdminService dashBdAdminService;


    /**
     * 남은 예산
     * @return 예산
     */
    @GetMapping("/budget")
    public Long budget() {
        Long result = this.dashBdAdminService.budget();

        return result;
    }

    /**
     * 전체 사원 수
     * @return 전체 사원 수
     */
    @GetMapping("/emp")
    public int emp () {
        int result = this.dashBdAdminService.emp();

        return result;
    }

    /**
     * 진행중인 프로젝트
     * @return 진행중인 프로젝트 수
     */
    @GetMapping("/proj")
    public int proj () {
        int result = this.dashBdAdminService.proj();

        return result;
    }

    /**
     * 이번달 신고건수
     * @return 이번달 신고건수
     */
    @GetMapping("/complaint")
    public int complaint() {
        int result = this.dashBdAdminService.complaint();

        return result;
    }




}
