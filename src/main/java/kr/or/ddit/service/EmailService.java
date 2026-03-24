package kr.or.ddit.service;

import kr.or.ddit.vo.EmailBoxVO;
import kr.or.ddit.vo.EmailReceiverVO;
import kr.or.ddit.vo.EmailVO;

import java.util.List;
import java.util.Map;

public interface EmailService {
    int sendMail(EmailVO emailVO, List<String> keepFileIds);
    //리스트
    int getTotalCount(Map<String, Object> map);
    List<EmailVO> getList(Map<String, Object> map);

    //받은메일함 리스트
    int getTotalSendCount(Map<String, Object> map);
    List<EmailVO> getSendList(Map<String, Object> map);

    //휴지통리스트
    int getTotalTrashCount(Map<String, Object> map);
    List<EmailVO> getTrashList(Map<String, Object> map);

    //이메일 상세 불러오기
    EmailVO findByNo(int emlRcvrId);
    //체크박스처리
    int readOrDelOrImpt(Map<String, Object> params);
    //중요메일처리
    int isImpt(String setImpt, int emlRcvrId);

    //상단바 메일 알람
    List<EmailVO> getNotReadMail(int empId);

    EmailVO findByNoSend(int emlNo);
    //수신확인을 위해 emailVO에 다수의 emailRcvrVO리스트를 포함해 가져옴
    EmailVO findByEmlNoForRcpchk(int emlNo);

    //관리자용 모든 리스트
    int getAdminListAllTotalCount(Map<String, Object> map);
    //관리자용 모든 리스트
    List<EmailVO> getAdminListAllList(Map<String, Object> map);

    int reCallEmail(int emlNo);

    //메일박스 가져오기
    List<EmailBoxVO> getemailBoxVOList(int empId);
    //메일박스 이름 변경
    int updateBox(EmailBoxVO emailBoxVO);
    //메일박스 추가
    int insertBox(EmailBoxVO emailBoxVO);
    //메일박스 삭제
    int deleteBox(EmailBoxVO emailBoxVO);

    int checkMailExist(EmailBoxVO emailBoxVO);

    int deletePmntOrRecall(Map<String, Object> params);
}
