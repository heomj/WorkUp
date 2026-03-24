package kr.or.ddit.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.or.ddit.mapper.CalendarMapper;
import kr.or.ddit.mapper.ClubMapper;
import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.service.CalendarService;
import kr.or.ddit.service.ClubService;
import kr.or.ddit.util.UploadController;
import kr.or.ddit.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class ClubServiceImpl implements ClubService {

	@Autowired
	ClubMapper clubMapper;

	//파일 업로드
	@Autowired
	UploadController uploadController;

	//동호회 회원인지 아닌지 확인
	@Override
	public ClubMemberVO getClubMember(ClubMemberVO clubMemberVO) {
		return this.clubMapper.getClubMember(clubMemberVO);
	}
	
	//가입
	@Transactional
	@Override
	public int join(ClubMemberVO clubMemberVO) {

		int result = this.clubMapper.join(clubMemberVO);

		//가입자 이름, 직급, 부서명 꺼내기
		String empNm = clubMemberVO.getEmpNm();
		String empJbgd = clubMemberVO.getEmpJbgd();
		String deptNm = clubMemberVO.getDeptNm();


		// 가입이 성공적으로 DB에 들어갔다면? -> 공지사항 자동 작성
		if (result > 0) {
			ClubNoticeVO noticeVO = new ClubNoticeVO();

			// 필수 데이터 세팅
			noticeVO.setClubNo(clubMemberVO.getClubNo());
			noticeVO.setEmpId(clubMemberVO.getEmpId()); // 작성자는 가입한 본인 사번

			// 제목과 내용 세팅
			noticeVO.setClubNtcTtl(empNm+"("+empJbgd+", "+deptNm+")님이 신규 가입 하였습니다.");

			String content = "우리 동호회에 새로운 가족이 생겼습니다. 모두 환영해 주세요!\n\n"
					+ "가입 인사: " + clubMemberVO.getClubJoinGret();
			noticeVO.setClubNtcCn(content);

			// 매퍼를 통해 공지사항 Insert
			this.clubMapper.noticeWrite(noticeVO);
		}

		return result;

	}


	//동호회 회원 목록 가져오기
	@Override
	public List<ClubMemberVO> getClubMemberList(int clubNo) {
		return this.clubMapper.getClubMemberList(clubNo);
	}


	//동호회 번호로 동호회 정보 가져오기
	@Override
	public ClubVO getClubInfo(int i) {
		return this.clubMapper.getClubInfo(i);
	}

	//동호회 회원 수 가져오기
	@Override
	public int getClubMemberCount(int i) {
		return this.clubMapper.getClubMemberCount(i);
	}


	// 동호회 탈퇴
	@Override
	public int leaveClub(ClubMemberVO clubMemberVO) {
		return this.clubMapper.leaveClub(clubMemberVO);
	}

	//동호회 공지사항 총 개수
	@Override
	public int getClubNoticeTotal(Map<String, Object> map) {
		return this.clubMapper.getClubNoticeTotal(map);
	}

	//동호회 공지사항 리스트 가져오기
	@Override
	public List<ClubNoticeVO> clubNoticeListAxios(ClubNoticeVO clubNoticeVO) {
		return this.clubMapper.clubNoticeListAxios(clubNoticeVO);
	}

	//동호회 공지사항 조회수 up
	@Override
	public int plusClubNoticeCnt(int clubNtcNo) {
		return this.clubMapper.plusClubNoticeCnt(clubNtcNo);
	}

	//동호회 공지사항 상세 불러오기
	@Override
	public ClubNoticeVO clubNoticeDetail(int clubNtcNo) {
		return this.clubMapper.clubNoticeDetail(clubNtcNo);
	}

	//동호회 공지사항 쓰기
	@Override
	public int noticeWrite(ClubNoticeVO clubNoticeVO) {
		return this.clubMapper.noticeWrite(clubNoticeVO);
	}

	//공지사항 삭제하기ㄴ
	@Override
	public int noticeDelete(int clubNtcNo) {
		return this.clubMapper.noticeDelete(clubNtcNo);
	}

	//포토갤러리 작성하기(첨부파일까지 insert)
	@Transactional
	@Override
	public int galleryWrite(ClubBoradVO clubBoradVO) {

		MultipartFile[] multipartFiles = clubBoradVO.getMultipartFiles();


		Long res = 0L;

		//첨부파일 있으면..
		if(multipartFiles!=null&&multipartFiles[0].getOriginalFilename().length()>0) {
			//첨부파일 객체 생성
			FileTbVO fileTbVO = new FileTbVO();
			fileTbVO.setEmpId(clubBoradVO.getClubMbrNo()); //작성자 setting
			fileTbVO.setFileStts("CLUBBOARD"); //상태는 동호회게시판으로

			//결과는 첨부파일 번호
			res =
					this.uploadController.multiFileUpload(multipartFiles, fileTbVO);
		}

		//파일번호 확인
		log.info("processAddProduct->rres:"+res);
		clubBoradVO.setClubBbsFileNo(res); //파일 번호 넣기
		int result = this.clubMapper.galleryWrite(clubBoradVO);

		return result;
	}//동호회 포토갤러리 insert 끝

	//포토 갤러리 게시글 개수
	@Override
	public int getClubBoardTotal(Map<String, Object> map) {
		return this.clubMapper.getClubBoardTotal(map);
	}

	//포토 갤러리 리스트
	@Override
	public List<ClubBoradVO> clubBoardListAxios(ClubBoradVO clubBoradVO) {
		return this.clubMapper.clubBoardListAxios(clubBoradVO);
	}

	//동호회 포토갤러리 조회수 up
	@Override
	public int plusClubBoardCnt(int clubBbsNo) {
		return this.clubMapper.plusClubBoardCnt(clubBbsNo);
	}

	//동호회 포토 갤러리 상세 가져오기
	@Override
	public ClubBoradVO clubBoardDetail(int clubBbsNo) {
		return this.clubMapper.clubBoardDetail(clubBbsNo);
	}

	//포토 갤러리 삭제하기
	@Override
	public int galleryDelete(int clubBbsNo) {
		return this.clubMapper.galleryDelete(clubBbsNo);
	}


	// /////////////////도서관 API////////////////////////////////
	// api키, 주소 세팅..
	private final String apiKey = "";
	private final String baseUrl = "http://data4library.kr/api";

	// 공용 파일(@Bean)을 건드리지 않기 위해 클래스 내부에서 직접 생성!
	private final RestTemplate restTemplate = new RestTemplate();
	private final ObjectMapper objectMapper = new ObjectMapper();

	@Override
	public List<Map<String, Object>> getDynamicBookContents() {
		List<Map<String, Object>> bookContents = new ArrayList<>();

		// 1. 표지 (프론트 디자인 유지를 위한 고정값)
		bookContents.add(createTitlePage());

		// 2. 이달의 키워드 (상위 6개)
		try {
			bookContents.add(getPopularKeywords());
		} catch (Exception e) {
			log.error("키워드 로딩 실패: ", e);
		}

		// 3. 대출 급상승 도서 (상위 3권)
		try {
			bookContents.addAll(getHotTrendBooks());
		} catch (Exception e) {
			log.error("급상승 도서 로딩 실패: ", e);
		}

		// 4. 오늘의 문장 (디자인 유지를 위한 고정값)
		bookContents.add(createQuotePage("책 없는 방은 영혼 없는 육체와 같다."));

		// 5. 인기 대출 도서 (대전 지역 베스트셀러 1권 추천)
		try {
			bookContents.add(getMonthlyRecommendation());
		} catch (Exception e) {
			log.error("추천 도서 로딩 실패: ", e);
		}

		return bookContents;
	}


	/**
	 * (관리자) 동호회 목록 가져오기(동호회 정보)
	 * @return List<ClubVO> 동호회 목록
	 */
	@Override
	public List<ClubVO> getClubList() {
		return this.clubMapper.getClubList();
	}


	/**
	 * 관리자 페이지 동호회 게시글 월별 차트 값
	 * @return 월별 게시글 List Map
	 */
	@Override
	public List<Map<String, Object>> getClubMonthlyActivity() {
		return this.clubMapper.getClubMonthlyActivity();
	}


	//대시보드에 포토갤러리 띄우기
	@Override
	public List<ClubBoradVO> getRecentClubPhotos() {
		return this.clubMapper.getRecentClubPhotos();
	}

	//(관리자) 동호회 회원 리스트
	@Override
	public List<ClubMemberVO> clubMemberList() {
		return this.clubMapper.clubMemberList();
	}

	//(관리자) 동호회 공지사항 리스트
	@Override
	public List<ClubNoticeVO> clubNoticeList() {
		return this.clubMapper.clubNoticeList();
	}

	//(관리자) 동호회 갤러리 리스트
	@Override
	public List<ClubBoradVO> clubGalleryList() {
		return this.clubMapper.clubGalleryList();
	}


	// ==========================================
	// 내부 API 호출 및 파싱 메서드 (Private)
	// ==========================================

	private Map<String, Object> getPopularKeywords() throws Exception {
		String url = UriComponentsBuilder.fromHttpUrl(baseUrl + "/monthlyKeywords")
				.queryParam("authKey", apiKey)
				.queryParam("format", "json")
				.toUriString();

		String response = restTemplate.getForObject(url, String.class);
		JsonNode root = objectMapper.readTree(response);
		JsonNode keywordsNode = root.path("response").path("keywords");

		List<String> keywordsList = new ArrayList<>();
		int count = 0;
		if (!keywordsNode.isMissingNode()) {
			for (JsonNode node : keywordsNode) {
				if (count >= 6) break;
				keywordsList.add("#" + node.path("keyword").path("word").asText());
				count++;
			}
		}

		Map<String, Object> map = new HashMap<>();
		map.put("type", "cloud");
		map.put("title", "이달의 키워드");
		map.put("data", keywordsList);
		return map;
	}

	private List<Map<String, Object>> getHotTrendBooks() throws Exception {
		// 공공데이터 집계 딜레이를 고려해 어제(1일전) -> 7일 전으로 안전하게 변경!
		String safeDate = LocalDate.now().minusDays(7).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

		String url = UriComponentsBuilder.fromHttpUrl(baseUrl + "/hotTrend")
				.queryParam("authKey", apiKey)
				.queryParam("searchDt", safeDate)
				.queryParam("format", "json")
				.toUriString();

		String response = restTemplate.getForObject(url, String.class);
		JsonNode root = objectMapper.readTree(response);

		JsonNode docsNode = root.path("response").path("results").get(0).path("result").path("docs");

		List<Map<String, Object>> hotTrendList = new ArrayList<>();
		int count = 0;

		if (!docsNode.isMissingNode() && docsNode.isArray()) {
			for (JsonNode node : docsNode) {
				if (count >= 3) break;
				JsonNode doc = node.path("doc");
				hotTrendList.add(createBookPage("대출 급상승 " + (count + 1) + "위", doc));
				count++;
			}
		}
		return hotTrendList;
	}

	private Map<String, Object> getMonthlyRecommendation() throws Exception {
		String url = UriComponentsBuilder.fromHttpUrl(baseUrl + "/loanItemSrchByLib")
				.queryParam("authKey", apiKey)
				.queryParam("region", "25")
				.queryParam("age", "30")
				.queryParam("format", "json")
				.toUriString();

		String response = restTemplate.getForObject(url, String.class);
		JsonNode root = objectMapper.readTree(response);

		JsonNode firstDoc = root.path("response").path("docs").get(0).path("doc");

		return createBookPage("대전 직장인 Pick!", firstDoc);
	}

	// ==========================================
	// 프론트 데이터 포맷팅 헬퍼 메서드
	// ==========================================

	private Map<String, Object> createTitlePage() {
		Map<String, Object> map = new HashMap<>();
		map.put("type", "title");
		map.put("title", "Page");
		map.put("data", "사내 독서 동호회<br>실시간 데이터 북");
		return map;
	}

	private Map<String, Object> createQuotePage(String quote) {
		Map<String, Object> map = new HashMap<>();
		map.put("type", "quote");
		map.put("title", "오늘의 문장");
		map.put("data", quote);
		return map;
	}

	private Map<String, Object> createBookPage(String title, JsonNode doc) {
		Map<String, Object> map = new HashMap<>();
		map.put("type", "book");
		map.put("title", title);

		Map<String, String> data = new HashMap<>();
		data.put("ttl", doc.path("bookname").asText());
		data.put("author", doc.path("authors").asText());
		data.put("img", doc.path("bookImageURL").asText());

		map.put("data", data);
		return map;
	}
	// /////////////////도서관 API////////////////////////////////









}
