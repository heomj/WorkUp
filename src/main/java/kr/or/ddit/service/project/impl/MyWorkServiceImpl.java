package kr.or.ddit.service.project.impl;

import kr.or.ddit.mapper.project.MyWorkMapper;
import kr.or.ddit.service.project.MyWorkService;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
public class MyWorkServiceImpl implements MyWorkService {
    @Autowired
    MyWorkMapper mapper;

    @Override
    public List<ProjectVO> toMyWorkList(int empId) {
        return this.mapper.toMyWorkList(empId);
    }

    @Override
    @Transactional
    public int updateTask(TaskVO taskVO) {
        if (taskVO.getTaskPrgrt() > 0 && "대기".equals(taskVO.getTaskStts())) {
            taskVO.setTaskStts("진행");

            log.info("업무 번호 {}번, 진척도 발생으로 '대기' -> '진행' 변경", taskVO.getTaskNo());
        }

        return this.mapper.updateTask(taskVO);
    }
}
