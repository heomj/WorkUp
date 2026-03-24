package kr.or.ddit.service.project.impl;


import kr.or.ddit.mapper.ApprovalMapper;
import kr.or.ddit.mapper.project.KanbanprojectMapper;
import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.service.project.KanbanprojectService;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskParticipantVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class KanbanprojectServiceImpl implements KanbanprojectService {

    @Autowired
    KanbanprojectMapper kanbanprojectMapper;

    @Autowired
    private SqlSession sqlSession; // Mybatis를 직접 제어하기 위해 주입

    //프로젝트 참가자 찾기
    @Override
    public List<EmployeeVO> findMembersByQuery(String query, int projNo) {
        return this.kanbanprojectMapper.findMembersByQuery(query, projNo);
    }

    //일감 리스트 불러오기
    @Override
    public List<TaskVO> getTasklist(int projNo) {
        return this.kanbanprojectMapper.getTasklist(projNo);
    }

    //일감 상태 변경
    @Transactional
    @Override
    public int updateTaskStts(TaskVO taskVO) {
        int result = 0;
        //일단 기존 일감
        result += this.kanbanprojectMapper.updateTaskStts(taskVO);

        log.info("지금 바꾸려는 일감의 프로젝트 번호가 들어오긴 하니? : {}", taskVO.getProjNo());
        log.info("지금 바꾸려는 일감의 상태는..? : {}", taskVO.getTaskStts());



        //바꾸려는 상태 도착이 '지연'일 때
        if ("지연".equals(taskVO.getTaskStts())) {
            // 프로젝트 상태도 무조건 '지연'으로 수정
            this.kanbanprojectMapper.updateProjectStatus(taskVO.getProjNo(), "지연");
        }

        // 바꾸려는 상태 도착이 '지연'외의 다른것일때
        else {
            // 현재 프로젝트에 남은 '지연' 일감이 있는지 개수 셈
            int delayedCount = this.kanbanprojectMapper.countDelayedTasks(taskVO.getProjNo());

            // 지연 일감이 단 한 개도 없다면?
            if (delayedCount == 0) {
                // 프로젝트 상태를 다시 정상인 '진행'으로 복구함
                result += this.kanbanprojectMapper.updateProjectStatus(taskVO.getProjNo(), "진행");
            }
        }
        return result;
    }

    //새일감 넣기
    @Transactional
    @Override
    public int insertTask(TaskVO taskVO) {

        // 일감(TASK) 먼저 등록!
        // selectKey로 taskNo가져오기..
        int result = this.kanbanprojectMapper.insertTask(taskVO);

        //담당자 리스트가 있다면?
        if(taskVO.getTaskParticipantVOList() != null && !taskVO.getTaskParticipantVOList().isEmpty()) {

            // 담당자 반복하면서 참여자 테이블에 INSERT
            for(TaskParticipantVO participant : taskVO.getTaskParticipantVOList()) {

                //selectKey로 가져온 일감번호 넣기..
                participant.setTaskNo(taskVO.getTaskNo());

                // 담당자 INSERT 실행!
                this.kanbanprojectMapper.insertTaskParticipant(participant);
            }//end for
        }//end if

        return result;
    }

    //프로젝트 이름 불러오기
    @Override
    public ProjectVO getProject(int projNo) {
        return this.kanbanprojectMapper.getProject(projNo);
    }

    /**
     * 일감 수정하기(팀장만)
     * @param taskVO 일감 폼 데이터
     * @return update 된 수
     */
    @Override
    public int updateTask(TaskVO taskVO) {


        // 일감 수정
        int result = this.kanbanprojectMapper.updateTask(taskVO);

        //일감 담당자 다 지우기
        this.kanbanprojectMapper.deleteTaskParticipant(taskVO.getTaskNo());

        // 프론트에서 새로 넘어온 담당자 리스트가 있다면?
        if(taskVO.getTaskParticipantVOList() != null && !taskVO.getTaskParticipantVOList().isEmpty()) {

            // 새 담당자들을 하나씩 꺼내서 참여자 테이블에 새로 INSERT!
            for(TaskParticipantVO participant : taskVO.getTaskParticipantVOList()) {

                // 어떤 일감의 담당자인지 set
                participant.setTaskNo(taskVO.getTaskNo());

                // 담당자 INSERT 실행!
                this.kanbanprojectMapper.insertTaskParticipant(participant);

            }//end for
        }//end if

        return result;

    }


}
