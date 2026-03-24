package kr.or.ddit.vo;

import java.util.Date;
import java.util.List;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class EmployeeVO {

    private int empId;
    private int deptCd;
    private String empPw;
    private String empNm;
    private String empBir;
    private String empPhone;
    private String empEml;
    private String empDomainEml;
    private String empZip;
    private String empAdd1;
    private String empAdd2;
    private String empProfile;
    private Date empRegistDt;
    private String empSign;
    private Date empLastDt;
    private int empMlg;
    private String empStts;
    private String empJbgd;  // 직급(사워, 주임, 대리, 팀장)
    private String empRole;  // 권한(사원, 팀장, 관리자)
    
    // JOIN 결과
    private String deptNm;     // 부서명

    private int avtNo;  // 아바타 번호
    private String avtSaveNm; // 아바타 파일명

    
    // 팀장 아래에 속한 사원들 리스트
    private List<EmployeeVO> teamEmployee;
    private List<EmployeeVO> deptEmployee;

    private DepartmentVO departmentVO;

    // 프로필, 사인 img 파일
    private MultipartFile prof;
    private MultipartFile sign;

    // 임시 비밀번호
    private int tmprPswdNo;
    private String tmprPswd;

    // 참여 프로젝트 수
    private int projectCount;

    //데쉬보드 근태형황
    private String attWorkStts;
}
