package kr.or.ddit.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Slf4j
@Controller
public class DashboardController {

    @GetMapping("/dashboardTest")
    public String emailTrashCan(Model model) {
        model.addAttribute("contentPage", "CustomJSP");
        return "main";
    }

    @GetMapping("/dashboardTest2")
    public String emailTrashCan2() {
        return "CustomJSP2";
    }

}
