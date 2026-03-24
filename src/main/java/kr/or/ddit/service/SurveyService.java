package kr.or.ddit.service;

import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.SurveyVO;

import java.util.List;
import java.util.Map;

public interface SurveyService {

    // 설문 생성
    public int insertSurvey(SurveyVO surveyVO);

    // 참여 가능한 설문
    public List<SurveyVO> newList(int loginId);

    // 참여한 설문
    public List<SurveyVO> mineList(int loginId);

    // 종료된 설문
    public List<SurveyVO> closedList(int loginId);

    // 설문 상세 조회
    public SurveyVO surveyDetail(int srvyNo);

    // 설문 응답 제출
    public int surveySubmit(SurveyVO surveyVO);

    // 설문 통계
    public SurveyVO statsData(int srvyNo);

    // [관리자] --------------------------------------------

    // 설문 리스트
    public List<SurveyVO> allList();

    // 종료 상태로 변경
    public int updateStts();

    // 알림 전송할 사원ID 가져오기
    public List<EmployeeVO> SurveyAllEmpIds();

    // 설문 수정
    public int updateSurvey(SurveyVO surveyVO);

    // 설문 삭제
    public int deleteSurveys(List<SurveyVO> srvyNo);

    // 설문 상태 일괄 종료로 변경
    public int updateSttsSurvey(List<SurveyVO> surveyList);

    // 통계
    public SurveyVO surveyStats();

    // 부서별 통계 리스트
    public List<Map<String, Object>> deptStatsList(int srvyNo);

    // 직급별 통계 리스트
    public List<Map<String, Object>> rankStatsList(int srvyNo);

    // 재직 사원 총 인원수
    public int totalEmpCount();

    // 개별 응답 상세
    public List<Map<String, Object>> individualAnswer(Long srvyNo);
}
