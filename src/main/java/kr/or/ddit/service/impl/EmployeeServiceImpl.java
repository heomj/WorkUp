package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.EmailMapper;
import kr.or.ddit.mapper.EmployeeMapper;
import kr.or.ddit.service.EmployeeService;
import kr.or.ddit.vo.EmailVO;
import kr.or.ddit.vo.EmployeeVO;
import net.nurigo.sdk.NurigoApp;
import net.nurigo.sdk.message.model.Message;
import net.nurigo.sdk.message.request.SingleMessageSendingRequest;
import net.nurigo.sdk.message.response.SingleMessageSentResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import net.nurigo.sdk.message.model.Message;
import net.nurigo.sdk.message.request.SingleMessageSendingRequest;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class EmployeeServiceImpl implements EmployeeService {

    @Autowired
    EmployeeMapper employeeMapper;
    @Autowired
    EmailMapper emailMapper;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    private String fromNumber;   // 문자를 보낼 때 사용하는 발신자 번호 담기
    private net.nurigo.sdk.message.service.DefaultMessageService messageService;  // 실제 문자를 전송해주는 도구 ?

    public EmployeeServiceImpl() {
        // 인텔리제이 환경변수에서 솔라피 키 가져오기
        String apiKey = System.getenv("COOLSMS_API_KEY");
        String apiSecret = System.getenv("COOLSMS_API_SECRET");

        this.fromNumber = System.getenv("COOLSMS_SENDER");

        // 솔라피 서비스 초기화
//        this.messageService = NurigoApp.INSTANCE.initialize(apiKey, apiSecret, "https://api.solapi.com");
    }



    //멘션기능 (@query > query가 포함된 empId 또는 empNm로 EmployeeVO 전부 찾기>리스트)
    @Override
    public List<EmployeeVO> findMembersByQuery(String query) {
        return this.employeeMapper.findMembersByQuery(query);
    }

    // 내 마이페이지 수정
    @Override
    public int updateprof(EmployeeVO vo) {
        return this.employeeMapper.updateprof(vo);
    }

    //사원의 이메일 조회
    @Override
    public EmployeeVO findEmployeeByEmail(String email) {
        return this.employeeMapper.findEmployeeByEmail(email);
    }

    // 사원 list 가져오기
    @Override
    public List<EmployeeVO> emplist() {
        return this.employeeMapper.emplist();
    }

    // 사원 부서 이동 시키기
    @Override
    public int updateDept(EmployeeVO vo) {
        return this.employeeMapper.updateDept(vo);
    }

    // 직급 변경
    @Override
    public int updatejbgd(EmployeeVO vo) {
        return this.employeeMapper.updatejbgd(vo);
    }

    // 관리자 정보 가져오기
    @Override
    public EmployeeVO whoadmin(int userId) {
        return this.employeeMapper.whoadmin(userId);
    }

    // 사원 추가
    @Override
    public int insert(EmployeeVO vo) {
        return this.employeeMapper.insert(vo);
    }

    @Override
    public List<EmployeeVO> adminemplist() {
        return this.employeeMapper.adminemplist();
    }

    // (퇴직, 재직) 바꾸기
    @Override
    public int sttschg(EmployeeVO vo) {
        return this.employeeMapper.sttschg(vo);
    }

    // 차트 데이터 가져오기
    @Override
    public List<Map<String, Object>> empstts() {
        return this.employeeMapper.empstts();
    }


    // 사번/전화번호 체크
    @Transactional
    @Override
    public String findpw(EmployeeVO vo) {
        int result = this.employeeMapper.findpw(vo);

        System.out.println("검색 결과 개수: " + result);

        if(result > 0) {
            // 랜덤 비밀번호 생성
            String tempPw = UUID.randomUUID().toString().substring(0, 8);

            // 3. 비밀번호 암호화 후 DB 업데이트
            String encodedPw = passwordEncoder.encode(tempPw);

            int id = vo.getEmpId();

            EmployeeVO updatevo = new EmployeeVO();
            updatevo.setEmpId(id);
            updatevo.setEmpPw(encodedPw);
            updatevo.setTmprPswd(encodedPw);

            // 임시 비밀번호로 변경
            this.employeeMapper.updatepw(updatevo);
            // 임시 비밀번호로 변경(임시 비밀번호 테이블에 저장)
            this.employeeMapper.temporary(updatevo);

            // 솔라피로 문자 발송하기 !
            Message message = new Message();
            message.setFrom(fromNumber);  // 내 전화번호임
            message.setTo(vo.getEmpPhone());  // 사원 전화번호
            message.setText("[WORKUP] 임시비밀번호는 ["+tempPw+"] 입니다. 로그인 후 변경해주세요"); // 메시지

            try {
                //          this.messageService.sendOne(new SingleMessageSendingRequest(message));  // 메시지 보내기

                SingleMessageSentResponse response = this.messageService.sendOne(new SingleMessageSendingRequest(message));
                System.out.println("솔라피 응답: " + response); // 응답 결과 확인
                return "success";
            } catch (Exception e) {
                e.printStackTrace();
                return "fail";
            }
        }
        return "not_found";
    }



}
