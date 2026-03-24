package kr.or.ddit.service.project.impl;

import kr.or.ddit.mapper.project.AdminMapper;

import kr.or.ddit.service.project.AdminService;

import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;

import kr.or.ddit.vo.project.PrtpntVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;


// 프로젝트 관리 ( 팀장 )
@Slf4j
@Service
public class AdminServiceImpl implements AdminService {

    @Autowired
    AdminMapper adminMapper;

    // 프로젝트 생성 시 "사원들 조회하기(팀장빼고)"
    @Override
    public List<EmployeeVO> emplist() {
        return this.adminMapper.emplist();
    }

    // 프로젝트 생성 => 프로젝트tab (insert) 프로젝트참여자tab (insert)
    @Transactional
    @Override
    public String create(ProjectVO vo) {

        // 프로젝트tab (insert)
        int projectresult = this.adminMapper.createproject(vo);

        // 프로젝트참여자tab (insert)
        if (projectresult > 0 && vo.getPrtpntVOList() != null && !vo.getPrtpntVOList().isEmpty()) {

            for (PrtpntVO prtpntvo : vo.getPrtpntVOList()) {
                // PrtpntVO에게 프로젝트 번호 부여 !
                prtpntvo.setProjNo(vo.getProjNo());
            }
            int particiresult = this.adminMapper.participant(vo.getPrtpntVOList());

            return particiresult > 0 ? "success" : "fail";
        }
        return projectresult > 0 ? "success" : "fail";
    }

    // 내가 만든 프로젝트 List 불러오기
    @Override
    public List<ProjectVO> myprojectlist(int empid) {
        List<ProjectVO> list = this.adminMapper.myprojectlist(empid);

        return this.adminMapper.myprojectlist(empid);
    }

    // 중요도(별)
    @Override
    public int staript(ProjectVO projectVO) {
        return this.adminMapper.staript(projectVO);
    }

    // 프로젝트 완료
    @Override
    public int finishpjt(ProjectVO projectVO) {
        return this.adminMapper.finishpjt(projectVO);
    }

    /**
     * 부서별 프로젝트 List / 일감 List / 참여자 List 조회
     * @param vo : 부서번호가 담긴
     * @return vo.deptCd 의 프로젝트 List / 일감 List / 참여자 List
     */
    @Override
    public List<ProjectVO> deptProjectList(int deptCd) {
        return this.adminMapper.deptProjectList(deptCd);
    }

    /**
     * 대시보드에서 진행중인 프로젝트 List 불러오기
     * @param empid 사용자 ID
     * @return 프로젝트 List
     */
    @Override
    public List<ProjectVO> dashboardProject(int empid) {
        return this.adminMapper.dashboardProject(empid);
    }

    /**
     * 프로젝트 참여자 제외하기
     * @return success / fail
     */
    @Transactional
    @Override
    public int removeParticipant(TaskVO vo) {

        int loneTaskCount = this.adminMapper.removetask(vo);

        log.info("제외 대상자 일감 수: {}", loneTaskCount);

        if (loneTaskCount > 0) {
            return 2;
        }

        try {
            // 일감 참여자 테이블에서 삭제 (해당 프로젝트 내 모든 일감)
            this.adminMapper.removeParticipant(vo);

            // 프로젝트 참여자 테이블에서 삭제
            return this.adminMapper.removeProjectMember(vo);
        } catch (Exception e) {
            log.error("삭제 중 오류 발생: {}", e.getMessage());
            throw e; // 트랜잭션 롤백을 위해 예외 던짐
        }

    }

    /**
     * 프로젝트에 참여자 추가하기
     * @param prtpntVO 참여자(id, name), 프로젝트id
     * @return 성공여부 (success / fail)
     */
    @Override
    public int addParticipant(PrtpntVO prtpntVO) {
        return this.adminMapper.addParticipant(prtpntVO);
    }

    // 프로젝트 이름 가져오기
    @Override
    public String projectname(int projNo) {
        return this.adminMapper.projectname(projNo);
    }
}
