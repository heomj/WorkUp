package kr.or.ddit.service.impl;


import kr.or.ddit.mapper.ApprovalMapper;
import kr.or.ddit.mapper.AttendanceMapper;
import kr.or.ddit.service.ApprovalService;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class ApprovalServiceImpl implements ApprovalService{

    @Autowired
    private ApprovalMapper approvalMapper;

    //연차 관리 테이블 업데이트를 위해
    @Autowired
    private AttendanceMapper attendanceMapper;

    @Autowired
    private SqlSession sqlSession; // Mybatis를 직접 제어하기 위해 주입

    //파일 업로드
    @Autowired
    UploadController uploadController;

    //문서 개수
    @Override
    public int getTotal(Map<String, Object> map) {
        return this.approvalMapper.getTotal(map);
    }

    //결재대기 문서 개수
    @Override
    public int getPendingTotal(Map<String, Object> map) {
        return this.approvalMapper.getPendingTotal(map);
    }

    //문서 목록
    @Override
    public List<ApprovalVO> list(Map<String, Object> map) {
        return this.approvalMapper.list(map);
    }

    //(관리자) 전체 문서 목록
    @Override
    public List<ApprovalVO> allList(Map<String, Object> map) {
        return this.approvalMapper.allList(map);
    }

    //결재대기 목록
    @Override
    public List<ApprovalVO> pendingList(Map<String, Object> map) {
        return this.approvalMapper.pendingList(map);
    }

    //결재선 가져오기
    @Override
    public List<AprvLineVO> getAprvLine(int aprvNo) {
        return this.approvalMapper.getAprvLine(aprvNo);
    }


    //결재문서 본문 가져오기
    @Override
    public ApprovalVO getCompleteDoc(int aprvNo) {
        // 먼저 양식 가져오기
        String aprvSe = this.approvalMapper.getAprvSe(aprvNo);

        // 해당 양식에 맞는 JOIN 쿼리 호출하여 이미 완성된 VO 받음
        // 매퍼 ID 규칙: "getPendingDoc_APRV01001"
        //                                           매퍼XML의                     namespace.id                    ,파라미터
        ApprovalVO aprvVO = sqlSession.selectOne("kr.or.ddit.mapper.ApprovalMapper.getPendingDoc_" + aprvSe, aprvNo);

        //첨부파일 아이디 가져오기
        Long fileId=aprvVO.getAprvData();

        //결재문서 첨부파일
        aprvVO.setFileTbVO(this.approvalMapper.getFileTbVO(fileId));
        log.info("서비스임플->첨부파일 담기->최종aprvVO : {}", aprvVO);


        return aprvVO;
    }
    
    
    //승인/반려 시 결재선 업데이트
    @Override
    public int aprvLineUpdate(AprvLineVO aprvLineVO) {
        return this.approvalMapper.aprvLineUpdate(aprvLineVO);
    }

    //승인/반려 시 결재문서 상태 업데이트
    @Override
    public int updateAprvStatus(AprvLineVO aprvLineVO) {
        return this.approvalMapper.updateAprvStatus(aprvLineVO);
    }

    //부서 문서함 문서 개수
    @Override
    public int getDeptAprvTotal(Map<String, Object> map) {
        return this.approvalMapper.getDeptAprvTotal(map);
    }

    //부서 문서함 리스트 가져오기
    @Override
    public List<ApprovalVO> deptAprvlist(Map<String, Object> map) {
        return this.approvalMapper.deptAprvlist(map);
    }

    //신청한(미결재) 초과근무 신청 내역 불러오기
    @Override
    public List<OvertimeDocumentVO> getOvertimeDocumentVOList(int empId) {
        return this.approvalMapper.getOvertimeDocumentVOList(empId);
    }


    //신청한(미결재) 휴가 신청 목록 가져오기
    @Override
    public List<VacationDocumentVO> getVacationDocumentVOList(int empId) {
        return this.approvalMapper.getVacationDocumentVOList(empId);
    }

    //신청한(미결재) 출장신청 목록 가져오기
    @Override
    public List<TripDocumentVO> getTripDocumentVOList(int empId) {
        return this.approvalMapper.getTripDocumentVOList(empId);
    }

    //결재문서 insert
    @Transactional
    @Override
    public int insertAprv(ApprovalVO approvalVO) {

        MultipartFile[] multipartFiles = approvalVO.getMultipartFiles();


        Long res = 0L;


        if(multipartFiles!=null&&multipartFiles[0].getOriginalFilename().length()>0) {
            FileTbVO fileTbVO = new FileTbVO();
            fileTbVO.setEmpId(approvalVO.getEmpId());
            fileTbVO.setFileStts("APRV");

            res =
                    this.uploadController.multiFileUpload(multipartFiles, fileTbVO);
        }

        log.info("processAddProduct->rres:"+res); //파일 번호 넣기
        approvalVO.setAprvData(res);
        int result = this.approvalMapper.insertAprv(approvalVO);

        return result;
    }


    //초과, 출장, 휴가 상태 업데이트 + 휴가면 연차관리 테이블도 업뎃..
    @Transactional
    @Override
    public int updateAttAprv(ApprovalVO approvalVO) {

        // 초과, 출장, 휴가에 따라서 매퍼
        int res =
                sqlSession.update("kr.or.ddit.mapper.ApprovalMapper.updateAttDoc_"
                                                + approvalVO.getAprvSe(), approvalVO);


        int deductResult = 0;

        // 만약 상신한 문서가 '휴가 신청(APRV01002)' 이라면 연차 차감 실행!
        if (res > 0 && "APRV01002".equals(approvalVO.getAprvSe())) {


            int empId = approvalVO.getEmpId();
            int attTypeId = approvalVO.getAprvDocNo();

            // 차감 쿼리 실행
            deductResult = this.attendanceMapper.updateEmpLeave(empId, attTypeId);

            if (deductResult > 0) {
                log.info("연차 관리 테이블 업뎃 성공");
            } else {
                log.info("연차 관리 테이블 업뎃 실패");
            }
        }

        return res+deductResult;
    }

    //결재선 insert
    @Override
    public int insertAprvLineVOList(List<AprvLineVO> list) {
        return this.approvalMapper.insertAprvLineVOList(list);
    }

    //상태 업데이트 하기..
    @Override
    public int updateDocStts(AprvLineVO aprvLineVO) {

        log.info("(회수) aprvLineVO에 AprvLnStts 대기로 바꾸는거 잘찍힘? {}", aprvLineVO);

        int res = sqlSession.update("kr.or.ddit.mapper.ApprovalMapper.updateDocStts_"
                + aprvLineVO.getAprvSe(), aprvLineVO);

        return res;
    }

    //휴가 돌려주기
    @Override
    public int returnUseVct(AprvLineVO aprvLineVO) {
        return this.approvalMapper.returnUseVct(aprvLineVO);
    }

    //(관리자용) 결재 문서 전체 조회
    @Override
    public int getTotalAll(Map<String, Object> map) {
        return this.approvalMapper.getTotalAll(map);
    }


    /**
     * 관리자 페이지) 예산에서 전자결재 검색하기
     * @param map 검색조건
     * @return 전자결재 리스트
     */
    @Override
    public List<ApprovalVO> searchBudgetAprvList(Map<String, Object> map) {
        return this.approvalMapper.searchBudgetAprvList(map);
    }

    //(관리자용) 부서 문서 점유율 도넛차트
    @Override
    public List<Map<String, Object>> getDeptDocCount() {
        return this.approvalMapper.getDeptDocCount();
    }

    //(관리자용) 부서 월별 문서 막대그래프
    @Override
    public List<Map<String, Object>> getMonthlyDeptVolume() {
        return this.approvalMapper.getMonthlyDeptVolume();
    }

    //알반기안문 insert
    @Override
    public int insertNmlDoc(ApprovalVO approvalVO) {
        return this.approvalMapper.insertNmlDoc(approvalVO);
    }

    //(알람용) 전자결재 번호로 사번 가져오기
    @Override
    public ApprovalVO getDocWriterId(int aprvNo) {
        return this.approvalMapper.getDocWriterId(aprvNo);
    }

    //다음 결재자 사번 가져오기
    @Override
    public Integer getNextAprvLnId(int aprvNo) {
        return this.approvalMapper.getNextAprvLnId(aprvNo);
    }


    // 결재 수신함에서 내가 결재 완료한 문서 개수
    @Override
    public int getPendingDoneTotal(Map<String, Object> map) {
        return this.approvalMapper.getPendingDoneTotal(map);
    }

    // 결재 수신함에서 내가 결재 완료한 문서 리스트
    @Override
    public List<ApprovalVO> getPendingDonedoneList(Map<String, Object> map) {
        return this.approvalMapper.getPendingDonedoneList(map);
    }

    // 업무태그용) 진행중 프로젝트 목록
    @Override
    public List<ProjectVO> getIngProjectList(int empId) {
        return this.approvalMapper.getIngProjectList(empId);
    }
    // 업무태그용) 완료된 프로젝트 목록
    @Override
    public List<ProjectVO> getDoneProjectList(int empId) {
        return this.approvalMapper.getDoneProjectList(empId);
    }

    //품의를 위한 예산 리스트(잔액) 불러오기
    @Override
    public List<BudgetDetailVO> getBudgetListByDept(int deptCd) {
        return this.approvalMapper.getBudgetListByDept(deptCd);
    }

    //지출품의 마스터 테이블 insert
    @Override
    public void insertExpndDoc(ApprovalVO approvalVO) {
        this.approvalMapper.insertExpndDoc(approvalVO);
    }

    //지출품의 상세 insert (한행씩)
    @Override
    public void insertExpndDtl(ExpndDocVO expndDoc) {
        this.approvalMapper.insertExpndDtl(expndDoc);
    }

    //예산 비목테이블에 예산 사용량 업뎃
    @Override
    public int updateBudgetUsage(ExpndDocVO dtl) {
        return this.approvalMapper.updateBudgetUsage(dtl);
    }

    //예산 로그에 insert
    @Override
    public void insertBudgetLog(BudgetLogVO logVO) {
        this.approvalMapper.insertBudgetLog(logVO);
    }

    //결재 반려되면 예산돌려주고 로그 찍어주기
    @Override
    public void refundBudget(int aprvNo, int empId) {

        // 1. 해당 결재 문서(aprvNo)에 딸린 지출 상세 내역들을 모두 조회해 옴
        List<ExpndDocVO> dtlList = this.approvalMapper.getExpndDtlListByAprvNo(aprvNo);

        for(ExpndDocVO dtl : dtlList) {
            // 2. 예산 잔액 복구 (BGT_EXCN - expndAmt)
            this.approvalMapper.refundBudgetUsage(dtl);

            // 3. 예산 로그 기록 (반려 복구)
            BudgetLogVO logVO = new BudgetLogVO();
            logVO.setBgtMCd(dtl.getBgtMCd());
            logVO.setBgtCd(dtl.getBgtCd());
            logVO.setBgtChgSe("반려복구"); // 구분: 반려복구
            logVO.setBgtChgAmt((int)dtl.getExpndAmt()); // 플러스 값으로 기록
            logVO.setBgtChgRsn("결재 반려/회수로 인한 예산 선점 취소");
            logVO.setEmpId(empId); // 반려한 사람 사번
            logVO.setAprvNo(aprvNo);

            //예산 로그 찍음ㄴ
            this.approvalMapper.insertBudgetLog(logVO);

        }


    }

    //결재문서 상태를 회수로 바꾸기
    @Override
    public int withdrawDocument(int aprvNo) {
        return this.approvalMapper.withdrawDocument(aprvNo);
    }


    //회수 문서 개수 불러오기
    @Override
    public int getWithDrawTotal(Map<String, Object> map) {
        return this.approvalMapper.getWithDrawTotal(map);
    }

    //회수 문서 리스트 불러오기
    @Override
    public List<ApprovalVO> withDrawlist(Map<String, Object> map) {
        return this.approvalMapper.withDrawlist(map);
    }


}
