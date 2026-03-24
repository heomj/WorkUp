package kr.or.ddit.service.impl;

import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;

import java.util.Collection;
import java.util.Collections;

@Slf4j
public class CustomUser extends User {

    private EmployeeVO empVO;

    // user의 생성자를 처리해주는 생성자
    public CustomUser(String username, String password
            , Collection<? extends GrantedAuthority> authorities) {
        super(username, password, authorities);
    }

    public CustomUser(EmployeeVO empVO) {

        // EmployeeVO를 스프링 시큐리티에서 제공해주고 있는 UsersDetails 타입으로 변환
        // 회원정보를 보내줄테니 이제부터 프링이 너가 관리해줘(인증, 인가) 해줘
        // 여기가 약간 환전(?) 이라는 곳이래 .. (empVO.getEmpRole()) 이렇게 보내도 시큐리티에선 Collection으로 줘야한대

        super(String.valueOf(empVO.getEmpId()), empVO.getEmpPw()
                , Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + empVO.getEmpRole()))
        );
        log.info("customUser empVO ");
        this.empVO = empVO;
    }

    public EmployeeVO getEmpVO() {
        return this.empVO;
    }

    public void setEmpVO(EmployeeVO empVO) {
        this.empVO = empVO;
    }
}
