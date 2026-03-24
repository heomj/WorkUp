package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.SurveyMapper;
import kr.or.ddit.service.SurveyService;
import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.SurveyVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static kotlin.reflect.jvm.internal.impl.builtins.StandardNames.FqNames.list;

@Slf4j
@Service
public class SurveyServiceImpl implements SurveyService {

    @Autowired
    private SurveyMapper surveyMapper;


    @Transactional
    @Override
    public int insertSurvey(SurveyVO surveyVO) {

        int result = surveyMapper.insertSurveyMaster(surveyVO);
        int generatedSrvyNo = surveyVO.getSrvyNo();

        // [STEP 2] SURVEY_QUEST 테이블 저장 루프
        List<SurveyVO> questions = surveyVO.getQuestions();
        if (questions != null) {
            for (SurveyVO quest : questions) {
                quest.setSrvyNo(generatedSrvyNo); // 부모 설문번호 세팅

                surveyMapper.insertQuestion(quest);
                int generatedQuestNo = quest.getSrvyQuestNo(); // 문항 PK 추출

                // [STEP 3] SURVEY_QUEST_ITEM 테이블 저장 루프 (객관식일 때만)
                List<SurveyVO> items = quest.getItems();
                if (items != null && !items.isEmpty()) {
                    for (SurveyVO item : items) {
                        item.setSrvyNo(generatedSrvyNo);     // 설문번호 세팅
                        item.setSrvyQuestNo(generatedQuestNo); // 문항번호 세팅

                        surveyMapper.insertItem(item);
                    }
                }
            }
        }
        return result;
    }

    // 참여 가능한 설문 리스트
    @Override
    public List<SurveyVO> newList(int loginId) {
        return this.surveyMapper.newList(loginId);
    }

    // 참여한 설문 리스트
    @Override
    public List<SurveyVO> mineList(int loginId) {
        return this.surveyMapper.mineList(loginId);
    }

    // 종료된 설문
    @Override
    public List<SurveyVO> closedList(int loginId) {
        return this.surveyMapper.closedList(loginId);
    }

    // 설문 상세 조회
    @Override
    public SurveyVO surveyDetail(int srvyNo) {
        return this.surveyMapper.surveyDetail(srvyNo);
    }

    // 설문 응답 제출
    @Transactional
    @Override
    public int surveySubmit(SurveyVO surveyVO) {
        try {
            List<SurveyVO> questions = surveyVO.getQuestions();
            if (questions != null && !questions.isEmpty()) {
                int rewardMlg = surveyVO.getSrvyMlg();

                for (SurveyVO answer : questions) {
                    answer.setSrvyNo(surveyVO.getSrvyNo());
                    answer.setEmpId(surveyVO.getEmpId());
                    answer.setSrvyMlg(rewardMlg);
                    this.surveyMapper.insertAnswer(answer);
                }
            }

            // 참여 인원수 증가
            this.surveyMapper.incrementSurveyNope(surveyVO.getSrvyNo());

            // 마일리지 추가 (직원 총점 업데이트)
            int rewardMlg = surveyVO.getSrvyMlg();
            if (rewardMlg > 0) {
                EmployeeVO empVO = new EmployeeVO();
                empVO.setEmpId(surveyVO.getEmpId());
                empVO.setEmpMlg(rewardMlg);
                this.surveyMapper.addMlg(empVO);
                log.info("사원 {}에게 마일리지 {}점 적립 완료", surveyVO.getEmpId(), rewardMlg);
            }
            return 1;
        } catch (Exception e) {
            log.error("설문 제출 중 에러 발생: ", e);
            throw new RuntimeException(e);
        }
    }


    // 설문 통계
    @Override
    public SurveyVO statsData(int srvyNo) {

        SurveyVO vo = surveyMapper.statsData(srvyNo);

        if(vo == null) {
            log.warn("{}번 설문 데이터가 없습니다.", srvyNo);
        }
        return vo;
    }




    // [관리자]

    // 설문 리스트
    @Override
    public List<SurveyVO> allList() {
        return this.surveyMapper.allList();
    }

    @Transactional
    @Override
    public int updateStts() {
        return this.surveyMapper.updateStts();
    }


    // 알림 전송할 사원ID 가져오기
    @Override
    public List<EmployeeVO> SurveyAllEmpIds() {
        return this.surveyMapper.SurveyAllEmpIds();
    }

    // 설문 수정
    @Override
    public int updateSurvey(SurveyVO surveyVO) {
        return this.surveyMapper.updateSurvey(surveyVO);
    }

    // 설문 삭제
    @Override
    public int deleteSurveys(List<SurveyVO> srvyNo) {
        return this.surveyMapper.deleteSurveys(srvyNo);
    }

    // 설문 상태 일괄 종료로 변경
    @Override
    public int updateSttsSurvey(List<SurveyVO> surveyList) {
        return this.surveyMapper.updateSttsSurvey(surveyList);
    }

    // 통계
    @Override
    public SurveyVO surveyStats() {
        // 기본 통계
        SurveyVO stats = surveyMapper.surveyStats();

        // 평균 참여율
        SurveyVO avgSurvey = surveyMapper.avgSurvey();

        // 데이터 합치기
        if (avgSurvey != null) {
            stats.setAveData(avgSurvey.getAveData());
        }

        // 총 재직자 수
        if (stats != null) {
            int total = this.totalEmpCount();
            stats.setTotalEmpCount(total);
            log.info("전체 설문 통계 생성 - 총 사원 수: {}", total);
        }

        return stats;
    }

    /**
     * 부서별 통계 리스트
     * @param srvyNo
     * @return
     */
    @Override
    public List<Map<String, Object>> deptStatsList(int srvyNo) {
        // 0이면 전체, 0보다 크면 개별 통계를 매퍼에서 처리함
        return surveyMapper.deptStats(srvyNo);
    }

    /**
     * 직급별 통계 리스트
     * @param srvyNo
     */
    @Override
    public List<Map<String, Object>> rankStatsList(int srvyNo) {
        // 0이면 전체, 0보다 크면 개별 통계를 매퍼에서 처리함
        return surveyMapper.rankStats(srvyNo);
    }

    /**
     * 재직 사원 총 인원수
     */
    @Override
    public int totalEmpCount() {
        return surveyMapper.totalEmpCount();
    }

    /**
     * 개별 응답 상세
     * @param srvyNo
     */
    @Override
    public List<Map<String, Object>> individualAnswer(Long srvyNo) {
        return surveyMapper.individualAnswer(srvyNo);
    }


}
