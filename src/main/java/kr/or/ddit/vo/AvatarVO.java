package kr.or.ddit.vo;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;

@Data
public class AvatarVO {
    private int avtNo;  // 아바타 번호
    private String avtCtg;  // 아바타 카테고리
    private int avtPrice;  // 아바타 가격
    private String avtNm;  // 아바타 이름
    private String avtSaveDt;  // 저장경로
    private String avtSaveNm; // 저장파일명
    private String avtONm;  // 원본파일명
    private Date avtDt;  // 최초등록시점
    private String avtYn; // 삭제여부

    // 아바타 이미지
    private MultipartFile avtimg;

}
