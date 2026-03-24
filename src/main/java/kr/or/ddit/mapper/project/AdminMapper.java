package kr.or.ddit.mapper.project;

import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.PrtpntVO;
import kr.or.ddit.vo.project.TaskVO;
import net.nurigo.sdk.message.model.Count;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface AdminMapper {

    // 프로젝트 생성 시 "사원들 조회하기(팀장빼고)"
    public List<EmployeeVO> emplist();

    // 프로젝트tab (insert)
    public int createproject(ProjectVO vo);

    // 프로젝트참여자tab (insert)
    public int participant(List<PrtpntVO> prtpntVOList);

    // 내가 담당하고 있는 프로젝트 List 불러오기
    public List<ProjectVO> myprojectlist(int empid);

    // 중요도(별)
    public int staript(ProjectVO projectVO);

    // 프로젝트 완료
    public int finishpjt(ProjectVO projectVO);

    /**
     * 부서별 프로젝트 List / 일감 List / 참여자 List 조회
     * @param deptCd : 부서번호
     * @return vo.deptCd 의 프로젝트 List / 일감 List / 참여자 List
     */
    public List<ProjectVO> deptProjectList(int deptCd);


    /**
     * 대시보드에서 진행중인 프로젝트 List 불러오기
     * @param empid 사용자 ID
     * @return 프로젝트 List
     */
    public List<ProjectVO> dashboardProject(int empid);


    // 제외자가 참여하는 일감들 중 혼자 맡고 있는지 세는 Count
    public int removetask(TaskVO vo);

    /**
     * 프로젝트 참여자 제외하기 (일감삭제)
     */
    public int removeParticipant(TaskVO vo);

    // 프로젝트 참여자 ㅔㅈ외
    public int removeProjectMember(TaskVO vo);

    /**
     * 프로젝트에 참여자 추가하기
     * @param prtpntVO 참여자(id, name), 프로젝트id
     * @return 성공여부 (success / fail)
     */
    public int addParticipant(PrtpntVO prtpntVO);

    // 알람을 위해 프로젝트 이름 가져온다 ..
    public String projectname(int projNo);
}
