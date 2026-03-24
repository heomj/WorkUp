package kr.or.ddit;

import kr.or.ddit.mapper.EmailMapper;
import kr.or.ddit.vo.EmailVO;
import lombok.extern.slf4j.Slf4j;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@SpringBootTest
class EmailApplicationTests {

    @Autowired
    EmailMapper emailMapper;

    @Test
    public void testEmailFindByEmpId(){
        //given
        int empid=1;
        //when
        Map<String, Object> map = new HashMap<String,Object>();
        map.put("currentPage", 1);// /list?currentPage=3 => 3, /list => 1
        map.put("empId", 1);

        List<EmailVO> emailVOList = this.emailMapper.getList(map);
        //than
        //Assertions.assertThat(emailVOList).isNotNull();
        Assertions.assertThat(emailVOList).isNotEmpty();
    }






    @Test
	void contextLoads() {
	}

}
