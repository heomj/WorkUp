package kr.or.ddit.service;


import kr.or.ddit.vo.EmailVO;
import kr.or.ddit.vo.EmployeeVO;

import java.util.List;
import java.util.Map;

public interface EmployeeService {

    //멘션기능 (@query > query가 포함된 empId 또는 empNm로 EmployeeVO 전부 찾기>리스트)
    List<EmployeeVO> findMembersByQuery(String query);

    // 내 마이페이지 수정
    public int updateprof(EmployeeVO vo);

    //사원의 이메일 조회
    public EmployeeVO findEmployeeByEmail(String email);


    // 사원 List 가져오기
    public List<EmployeeVO> emplist();

    // 사원 부서 이동 시키기
    public int updateDept(EmployeeVO vo);

    // 직급 변경하기
    public int updatejbgd(EmployeeVO vo);

    // 관리자 정보 가져오기
    public EmployeeVO whoadmin(int userId);

    // 사원 등록하기
    public int insert(EmployeeVO vo);

    // 관리자에서 사원 정보 가져오기
    public List<EmployeeVO> adminemplist();

    // (퇴직, 재직) 바꾸기
    public int sttschg(EmployeeVO vo);

    // 차트 데이터 가져오기
    public List<Map<String, Object>> empstts();

    // 사번, 비밀번호 있는지 !
    public String findpw(EmployeeVO vo);

}
