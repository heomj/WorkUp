package kr.or.ddit.mapper;

import kr.or.ddit.vo.EmployeeVO;
import org.apache.ibatis.annotations.MapKey;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface EmployeeMapper {

    // 사원번호로 사용자 정보를 가져옴(로그인)
    public EmployeeVO findByEmpId(int empid);

    //멘션기능 (@query > query가 포함된 empId 또는 empNm로 EmployeeVO 전부 찾기>리스트)
    List<EmployeeVO> findMembersByQuery(String query);

    // 내 마이페이지 수정
    public int updateprof(EmployeeVO vo);

    //사원의 이메일 조회
    public EmployeeVO findEmployeeByEmail(String email);

    // 사원List
    public List<EmployeeVO> emplist();

    // 사원 부서 이동 시키기
    public int updateDept(EmployeeVO vo);

    // 직급 변경
    public int updatejbgd(EmployeeVO vo);

    // 관리자 정보 가져오기
    public EmployeeVO whoadmin(int userId);

    // 사원 추가
    public int insert(EmployeeVO vo);

    // 관리자에서 사원 정보 가져오기
    public List<EmployeeVO> adminemplist();

    // 퇴직 / 재직
    public int sttschg(EmployeeVO vo);

    // 차트 데이터 가져오기
    @MapKey("EMP_ID")
    public List<Map<String, Object>> empstts(); // Map의 키값을 무엇으러 할 지 알아야 해서 @MapKey 써주기!

    // 사번/잔화번호 일치하는지
    public int findpw(EmployeeVO vo);

    // 비밀번호 업데이트 하기 !
    public void updatepw(EmployeeVO updatevo);

    // 테이블에 저장
    public void temporary(EmployeeVO updatevo);
}
