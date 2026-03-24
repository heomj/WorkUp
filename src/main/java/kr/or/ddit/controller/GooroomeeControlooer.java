package kr.or.ddit.controller;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.MediaType; // <- 여기 있어요!

import java.nio.charset.StandardCharsets;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.or.ddit.vo.GooroomeeVO;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import okhttp3.RequestBody;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLEncoder;

@JsonIgnoreProperties(ignoreUnknown = true)
@Slf4j
@Controller
@RequestMapping("/gooroomee")
public class GooroomeeControlooer {

    @GetMapping("/list")
    public String list( Model mav) throws IOException {
        OkHttpClient client = new OkHttpClient();
        List<Map<String, Object>> anyList=new ArrayList<>();
        Request request = new Request.Builder()
                .url("https://openapi.gooroomee.com/api/v1/room/list?page=1&limit=10&sortCurrJoinCnt=true")
                .get()
                .addHeader("accept", "application/json")
                .addHeader("X-GRM-AuthToken", "")
                .build();

        Response response = client.newCall(request).execute();

        log.info("response : {}" , response);
        List<GooroomeeVO> roomList = new ArrayList<>();
        // 2. 바디(JSON 문자열)를 꺼내기
        if (response.isSuccessful() && response.body() != null) {
            String responseBody = response.body().string(); // 여기서 JSON 문자열을 가져옴

// 2. ObjectMapper로s JSON 파싱
            ObjectMapper mapper = new ObjectMapper();

            JsonNode root = mapper.readTree(responseBody);

// 3. 'data' 안에 있는 'list'만 쏙 꺼내오기
            //자바를 제이슨/ 제이슨을 자바로 바꿔주는 게 잇음
            JsonNode listNode = root.get("data").get("list");

// 4. 리스트로 변환 (GooroomeeVO 객체들로 구성된 리스트)
            anyList = mapper.convertValue(
                    root.get("data").get("list"),
                    new TypeReference<List<Map<String, Object>>>() {}
            );

        }

        log.info("anylist:{}", anyList);

        mav.addAttribute("roomList", anyList);
        mav.addAttribute("contentPage", "gooroomee/gooroomeelist");
        return "main";
    }
@ResponseBody
    @PostMapping("/create")
    public String create(Model mav, @org.springframework.web.bind.annotation.RequestBody GooroomeeVO gooroomeeVO) throws IOException {
        OkHttpClient client = new OkHttpClient();
        String roomTitle=gooroomeeVO.getRoomTitle();
        String roomUrlId=gooroomeeVO.getRoomUrlId();
        log.info("roomTitle : {}", roomTitle);
        log.info("roomUrlId : {}", roomUrlId);

        okhttp3.MediaType mediaType = okhttp3.MediaType.parse("application/x-www-form-urlencoded");

        String paramString = "callType=P2P&liveMode=false&maxJoinCount=4&liveMaxJoinCount=100&layoutType=4&sfuIncludeAll=true";
            // 원하는 파라미터 추가
        paramString += "&roomTitle=" + URLEncoder.encode(roomTitle, StandardCharsets.UTF_8);
        paramString += "&roomUrlId=" + URLEncoder.encode(roomUrlId, StandardCharsets.UTF_8);

        RequestBody body = RequestBody.create(mediaType, paramString);

        Request request = new Request.Builder()
                .url("https://openapi.gooroomee.com/api/v1/room")
                .post(body)
                .addHeader("accept", "application/json")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .addHeader("X-GRM-AuthToken", "")
                .build();

        Response response = client.newCall(request).execute();
        return "SUCCESS";
    }

    @GetMapping("/join/{roomId}/{username}")
    public String joinGooroomee(@PathVariable String roomId, @PathVariable String username){
        String extractedUrl = "";
        String url = "https://openapi.gooroomee.com/api/v1/room/user/otp/url";
        RestTemplate restTemplate = new RestTemplate();



        // 1. 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.set("X-GRM-AuthToken", "");

        // 2. 바디 설정 (URLSearchParams 대신 MultiValueMap 사용)
        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("roleId", "participant");
        body.add("apiUserId", username);
        body.add("ignorePasswd", "false");
        body.add("roomId", roomId);
        body.add("username", username);

        // 3. 요청 생성
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(body, headers);

        // 4. API 호출
        try {
            ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);

            // 2. ObjectMapper를 사용하여 JSON 문자열을 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(response.getBody());

            // 3. 구조에 맞춰 경로 탐색: root -> data -> url
            extractedUrl = root.path("data").path("url").asText();

            log.info("원하는 정보가 왔을까? {}", extractedUrl);
        } catch (Exception e) { log.error("에러 발생 : {}", e);
        }
        return "redirect:"+extractedUrl;
    }

    @ResponseBody
    @DeleteMapping("/delete/{roomId}")
    public String delete(@PathVariable String roomId) throws IOException {
        OkHttpClient client = new OkHttpClient();

            log.info("구루미를 삭제하려고 합니다. : {}", roomId);
        Request request = new Request.Builder()
                .url("https://openapi.gooroomee.com/api/v1/room/"+roomId)
                .delete(null)
                .addHeader("accept", "application/json")
                .addHeader("X-GRM-AuthToken", "")
                .build();

        Response response = client.newCall(request).execute();
        return "SUCCESS";
    }

}
