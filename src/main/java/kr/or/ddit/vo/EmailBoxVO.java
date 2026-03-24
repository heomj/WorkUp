package kr.or.ddit.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;
import java.util.List;

@Data
public class EmailBoxVO {
    private String emlBoxTtl;
    private int emlBoxNo;
    private int emlBoxUpNo;
    private int empId;
    private int level;

}
