package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.EmailMapper;
import kr.or.ddit.service.EmailService;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.EmailBoxVO;
import kr.or.ddit.vo.EmailReceiverVO;
import kr.or.ddit.vo.EmailVO;
import kr.or.ddit.vo.FileTbVO;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
public class EmailServiceImpl implements EmailService {

    @Autowired
    EmailMapper emailMapper;

    @Autowired
    UploadController uploadController;
    @Autowired
    private SqlSession sqlSession;

    //이메일 보내기
    @Transactional
    @Override
    public int sendMail(EmailVO emailVO, List<String> keepFileIds) {

        MultipartFile[] multipartFiles = emailVO.getMultipartFiles();

        Long res = 0L;

        if(multipartFiles!=null&&multipartFiles[0].getOriginalFilename().length()>0) {
            FileTbVO fileTbVO = new FileTbVO();
            fileTbVO.setEmpId(emailVO.getEmlSndrId());
            fileTbVO.setFileStts("EMAIL");
            //				파일업로드+PRODUCT_FILE 테이블에 insert
            res =
                    this.uploadController.multiFileUpload( multipartFiles, fileTbVO);
        }
        //기존 파일을 복사함 (답장 또는 전달용)
        int resultoffile = 0;
        if(keepFileIds!=null && keepFileIds.size()>0){

            for(String oldFilestr : keepFileIds) {
                Map<String, Object> map = new HashMap<>();
                map.put("newFileId",res);
                map.put("empId",emailVO.getEmlSndrId());
                int oldFile = Integer.valueOf(oldFilestr);
                map.put("oldFileDtlId", oldFile);
                resultoffile+=this.emailMapper.copyFileDetail(map);
            }
        }


        log.info("processAddProduct->resultoffile:"+resultoffile); //몇건일까요
        log.info("processAddProduct->res:"+res); //1
        emailVO.setFileId(res);
        int result = this.emailMapper.sendMail(emailVO);

        //수신자 테이블 추가하기
        List<EmailReceiverVO> emailReceiverVOList = new ArrayList<EmailReceiverVO>();
        List<Integer> emlRcvrIds=emailVO.getEmlRcvrIds();
        if(emlRcvrIds!=null) {
            for (Integer emailReceiver : emlRcvrIds) {
                EmailReceiverVO emailReceiverVO = new EmailReceiverVO();
                emailReceiverVO.setEmpId(emailReceiver);
                emailReceiverVO.setEmlRcvrType("수신자");
                emailReceiverVO.setEmlNo(emailVO.getEmlNo());

                result += this.emailMapper.sendMailRCVR(emailReceiverVO);
            }
        }

        //참조자 테이블 추가하기
        List<EmailReceiverVO> emailReceiverCcVOList = new ArrayList<EmailReceiverVO>();
        List<Integer> emlCcIds=emailVO.getEmlCcIds();
        if(emlCcIds!=null) {
            for (Integer emlCcId : emlCcIds) {
                EmailReceiverVO emailReceiverVO = new EmailReceiverVO();
                emailReceiverVO.setEmpId(emlCcId);
                emailReceiverVO.setEmlRcvrType("참조자");
                emailReceiverVO.setEmlNo(emailVO.getEmlNo());

                result += this.emailMapper.sendMailRCVR(emailReceiverVO);
            }
        }
        log.info("processAddProduct->result 수신자+참조자+1:"+result);
        return result;
    }

    //리스트 수 카운트
    @Override
    public int getTotalCount(Map<String, Object> map) {
        return this.emailMapper.getTotalCount(map);
    }
    //리스트 받아오기
    @Override
    public List<EmailVO> getList(Map<String, Object> map) {
        //emailVO리스트 받아오기 (JOIN 이메일/받는사람/사원/부서)
        List<EmailVO> emailVOList = new ArrayList<EmailVO>();
        emailVOList=this.emailMapper.getList(map);

        return emailVOList;
    }

    //보낸 메일함 리스트 수 카운트
    @Override
    public int getTotalSendCount(Map<String, Object> map) {
        return this.emailMapper.getTotalSendCount(map);
    }
    //보낸 메일함 리스트 받아오기
    @Override
    public List<EmailVO> getSendList(Map<String, Object> map) {
        //emailVO리스트 받아오기 (JOIN 이메일/받는사람/사원/부서)
        List<EmailVO> emailVOList = new ArrayList<EmailVO>();
        emailVOList=this.emailMapper.getSendList(map);

        //각 emailVO리스트에 수신자 테이블 다 넣기
        for(EmailVO emailVO : emailVOList){
            List<EmailReceiverVO> emailReceiverVOList = this.emailMapper.getemailReceiverVOListByemlNo(emailVO.getEmlNo());
            emailVO.setEmailReceiverVOList(emailReceiverVOList);
        }
        // 3. 수신인 이름으로 필터링 (검색어가 있을 경우)
        // 3. 수신인 이름 또는 사번으로 필터링
        if ("emlRcvrId".equals(map.get("mode")) && map.get("keyword") != null) {
            String keyword = (String) map.get("keyword");

            return emailVOList.stream()
                    .filter(email -> email.getEmailReceiverVOList().stream()
                            .anyMatch(receiver -> {
                                // 1. 이름 체크 (Null 방지)
                                boolean nameMatch = receiver.getEmpNm() != null &&
                                        receiver.getEmpNm().contains(keyword);

                                // 2. 사번(int) 체크: String.valueOf()로 변환 후 contains 사용
                                // 만약 사번이 '정확히 일치'해야 한다면 .equals()나 == 를 사용하세요.
                                String empIdStr = String.valueOf(receiver.getEmpId());
                                boolean idMatch = empIdStr.contains(keyword);

                                return nameMatch || idMatch;
                            }))
                    .collect(Collectors.toList());
        }
        return emailVOList;
    }

    //휴지통 수 카운트
    @Override
    public int getTotalTrashCount(Map<String, Object> map) {
        return this.emailMapper.getTotalTrashCount(map);
    }
    //휴지통 리스트
    @Override
    public List<EmailVO> getTrashList(Map<String, Object> map) {
        //emailVO리스트 받아오기 (JOIN 이메일/받는사람/사원/부서)
        List<EmailVO> emailVOList = new ArrayList<EmailVO>();
        emailVOList=this.emailMapper.getTrashList(map);

        return emailVOList;
    }

    //상세보기 - 이메일 상세 불러오기
    @Override
    public EmailVO findByNo(int emlRcvrId) {
        //이메일 상세정보
        log.info("서비스임플->findByNo->emlRcvrId : {}", emlRcvrId);
        EmailVO emailVO = new EmailVO();
        emailVO =this.emailMapper.findByNo(emlRcvrId);
        log.info("서비스임플->findByNo->emailVO : {}", emailVO);
        Long fileId=emailVO.getFileId();
        //이메일 첨부파일
        emailVO.setFileTbVO(this.emailMapper.getFileTbVO(fileId));
        log.info("서비스임플->findByNo->최종emailVO : {}", emailVO);

        //읽음 처리
        int res = this.emailMapper.isRead(emlRcvrId);
        log.info("조회시 자동 읽음처리 : {}", res);

        return emailVO;
    }
    //다중 처리 중요,삭제,읽음  ++메일박스
    @Override
    public int readOrDelOrImpt(Map<String, Object> params) {
        int result = 0;
        //동작 확인하기 (삭제/중요/읽음)
        String readOrDelOrImpt =String.valueOf(params.get("readOrDelOrImpt"));
        log.info("readOrDelOrImpt 동작 확인하기 (삭제/중요/읽음) : {}", readOrDelOrImpt);

        if("updateMailbox".equals(readOrDelOrImpt)){
            List<?> list = (List<?>) params.get("emlNos");
            Object emlBoxNo= params.get("emlBoxNo");
            if (list != null) {
                for (Object item : list) {
                    Map<String, Object> updateParam = new HashMap<>();
                    Integer emlRcvrId = Integer.valueOf(String.valueOf(item));
                    updateParam.put("emlBoxNo", emlBoxNo);
                    updateParam.put("emlRcvrId", emlRcvrId);

                    // 숫자로 바꿈
                    log.info("list 꺼냄 : {}", emlRcvrId);
                    result += sqlSession.update(readOrDelOrImpt, updateParam );
                }
            }
        }else
        {
            //숫자배열 꺼내서 돌리기
            List<?> list = (List<?>) params.get("emlNos");
            if (list != null) {
                for (Object item : list) {
                    Integer num = Integer.valueOf(String.valueOf(item));
                    // 숫자로 바꿈
                    log.info("list 꺼냄 : {}", num);
                    result += sqlSession.update(readOrDelOrImpt, num);
                }
            }
        }
        //return this.emailMapper.readOrDelOrImpt();
        return result;
    }
    // 개별처리 중요, 삭제
    @Override
    public int isImpt(String setImpt, int emlRcvrId) {
        String setImptsql;
        if("Y".equals(setImpt)){    //
            setImptsql="isNotImpt";
        }else if("N".equals(setImpt)) {setImptsql="isImpt";
        }else {setImptsql="isDeleted";}

        int result=sqlSession.update(setImptsql, emlRcvrId);

        return result;
    }
    //상단바 메일 알람
    @Override
    public List<EmailVO> getNotReadMail(int empId) {
        return this.emailMapper.getNotReadMail(empId);
    }
    //버려짐..
    @Override
    public EmailVO findByNoSend(int emlNo) {
        EmailVO emailVO=this.emailMapper.findByNoSend(emlNo);

        log.info("서비스임플->findByNo->emailVO : {}", emailVO);
        Long fileId=emailVO.getFileId();
        //이메일 첨부파일
        emailVO.setFileTbVO(this.emailMapper.getFileTbVO(fileId));
        log.info("서비스임플->findByNo->최종emailVO : {}", emailVO);


        return emailVO;
    }

//수신인 체크 포함된 이메일 detail
    @Override
    public EmailVO findByEmlNoForRcpchk(int emlNo) {
        EmailVO emailVO = this.emailMapper.findByNoSend(emlNo);
        Long fileId=emailVO.getFileId();
        //이메일 첨부파일
        emailVO.setFileTbVO(this.emailMapper.getFileTbVO(fileId));
        log.info("서비스임플->findByNo->최종emailVO : {}", emailVO);
        emailVO.setEmailReceiverVOList(this.emailMapper.getAllemailReceiverVOListByemlNo(emlNo));
        return emailVO;
    }
    //관리자용 모든 리스트
    @Override
    public int getAdminListAllTotalCount(Map<String, Object> map) {
        return this.emailMapper.getAdminListAllTotalCount(map);
    }
    //관리자용 모든 리스트
    @Override
    public List<EmailVO> getAdminListAllList(Map<String, Object> map) {
        List<EmailVO> emailVOList = this.emailMapper.getAdminListAllList(map);
            int emlNo=0;
        for(EmailVO emailVO :emailVOList){
            emlNo=emailVO.getEmlNo();
            emailVO.setEmailReceiverVOList(this.emailMapper.getAllemailReceiverVOListByemlNo(emlNo));
        }

        return emailVOList;
    }
    //단건 회수 (보낸메일함)
    @Override
    public int reCallEmail(int emlNo) {
        return this.emailMapper.reCallEmail(emlNo);
    }

    //단건 복귀/영구삭제 (휴지통)
    public int deletePmntOrRecall(Map<String, Object> params) {
        String deletePmntOrRecall = String.valueOf(params.get("deletePmntOrRecall"));
        String emlRcvrIdstr = String.valueOf(params.get("emlRcvrId"));
        int emlRcvrId = Integer.valueOf(emlRcvrIdstr);
        int res =  sqlSession.update(deletePmntOrRecall, emlRcvrId );
        return res;
    }

    //메일박스 불러오기
    @Override
    public List<EmailBoxVO> getemailBoxVOList(int empId) {
        return this.emailMapper.getemailBoxVOList(empId);
    }
    //메일박스 이름 변경
    @Override
    public int updateBox(EmailBoxVO emailBoxVO) {
        return this.emailMapper.updateBox(emailBoxVO);
    }
    //메일박스 추가
    @Override
    public int insertBox(EmailBoxVO emailBoxVO) {
        return this.emailMapper.insertBox(emailBoxVO);
    }
    //메일박스 삭제
    @Override
    public int deleteBox(EmailBoxVO emailBoxVO) {
        return this.emailMapper.deleteBox(emailBoxVO);
    }
    @Override
    public int checkMailExist(EmailBoxVO emailBoxVO) {
        return this.emailMapper.checkMailExist(emailBoxVO);
    }


}
