package kr.or.ddit.mapper;

import kr.or.ddit.vo.EmailBoxVO;
import kr.or.ddit.vo.EmailReceiverVO;
import kr.or.ddit.vo.EmailVO;
import kr.or.ddit.vo.FileTbVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface EmailMapper {

    //이메일 상세 불러오기
    EmailVO findByNo(int emlRcvrId);
    //이메일 상세의 파일 가져오기
    FileTbVO getFileTbVO(Long field);
    //이메일 상세보기시 읽음처리
    int isRead(int emlRcvrId);
    //이메일 개별 중요처리 -토글저리하므로 ServiceImpl에서 sqlSession사용
    //int isImpt(int emlRcvrId);


    //이메일 INSERT
    int sendMail(EmailVO emailVO);

    //리스트 수 카운트
    int getTotalCount(Map<String, Object> map);
    //리스트 받아오기
    List<EmailVO> getList(Map<String, Object> map);

    //휴지통 수 카운트
    int getTotalTrashCount(Map<String, Object> map);
    //휴지통 받아오기
    List<EmailVO> getTrashList(Map<String, Object> map);

    //수신자 INSERT
    int sendMailRCVR(EmailReceiverVO emailReceiverVO);

    //상단바 메일 알람
    List<EmailVO> getNotReadMail(int empId);

    int getTotalSendCount(Map<String, Object> map);

    List<EmailVO> getSendList(Map<String, Object> map);

    EmailVO findByNoSend(int emlNo);
    //보낸메일함 리스트에서 수신확인을 위한 수신자 리스트 받아오기
    List<EmailReceiverVO> getemailReceiverVOListByemlNo(int emlNo);
    //보낸메일함 리스트에서 수신확인을 위한 수신자 리스트 받아오기 - 참조자 포함
    List<EmailReceiverVO> getAllemailReceiverVOListByemlNo(int emlNo);

    //관리자용 모든 리스트 카운트
    int getAdminListAllTotalCount(Map<String, Object> map);
    //관리자용 모든 리스트
    List<EmailVO> getAdminListAllList(Map<String, Object> map);

    //단건 회수
    int reCallEmail(int emlNo);

    List<EmailBoxVO> getemailBoxVOList(int empId);
    //메일박스 이름 변경
    int updateBox(EmailBoxVO emailBoxVO);
    //메일박스 추가
    int insertBox(EmailBoxVO emailBoxVO);
    //메일박스 삭제
    int deleteBox(EmailBoxVO emailBoxVO);

    int checkMailExist(EmailBoxVO emailBoxVO);
    //기존 파일을 복사하는 로직
    int copyFileDetail(Map<String, Object> map);
}
