package kr.or.ddit.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class AlarmVO {
    private int almId;      //알람 ID (기본키)
    private int empId;      //보낸사람
    private String almMsg;  //알람내용
    private String almDtl;  //알람내용 상세!
    private String almType; //어디서 사용한 알람인지

    private String almUrl;  //알람URL
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date almSndrTm;     //알람 보낸 시간
    private String almDelYn;   //삭제여부

    private String almSndrIcon; //알람 보낸사람 아이콘

    private String almIcon; //sweetAlert 종류
    //success, error, warning, info, question

    private List<Integer> almRcvrNos; //수신자 배열
    private int almRcvrNo; //수신자 한명의 경우
    private String almYn; //수신자 한명의 경우 읽음 여부..
    List<AlarmReceiveVO> alarmReceiveVOList;

    private String almUrlVar;
    // url 뒤에 붙는 커스텀 변수
    //(따로 지정하지 않으면 null값을 가짐)

    private String empProfile; //프로필
    private String avtSaveNm; // 아바타 파일명

}
