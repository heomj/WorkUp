package kr.or.ddit.service.impl;

import jakarta.servlet.http.HttpServletRequest;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

// UserDetailsService : 스프링 시큐리티에서 사용자 정보를 가져오는 인터페이스임 !
@Slf4j
@Service
public class RoleServiceImpl implements UserDetailsService {

    @Autowired
    private HttpServletRequest request;

    @Autowired
    EmployeeMapper employeeMapper;

    // 이거 UserDetailsService 에서 제공해줌 !
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 1. 화면에서 보낸 loginType(hidden 값) 가져오기
        String loginType = request.getParameter("loginType");

        log.info("UserDetails -> username : {}", username);

        // 시큐리티에서 받아온(username)으로 사용자 정보 검색
        // 시큐리티 컨피그에서 넘어온건 username(EmpId)는 Stirng .. 타입이라 int로 형변환 해야 하지 않나? 요
        EmployeeVO employeeVO = this.employeeMapper.findByEmpId(Integer.valueOf(username));


        if (employeeVO == null) {
            throw new UsernameNotFoundException("존재하지 않는 사용자입니다.");
        }

        String userRole = employeeVO.getEmpRole();
        log.info("사용자의 실제 직급/권한: {}", userRole);

        if ("admin".equals(loginType)) {
            if (!"관리자".equals(userRole)) {
                log.warn("차단: 관리자 권한 없는 사용자({})가 관리자 모드 접근", username);
                throw new BadCredentialsException("관리자만 접근 가능한 모드입니다.");
            }
        }

        else if ("employee".equals(loginType)) {
            if ("관리자".equals(userRole)) {
                log.warn("차단: 관리자({})가 사원 모드 접근", username);
                throw new BadCredentialsException("관리자는 관리자 로그인 모드를 이용해주세요.");
            }
        }
        return employeeVO == null ? null : new CustomUser(employeeVO);
    }
}
