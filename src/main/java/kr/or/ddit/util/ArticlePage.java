package kr.or.ddit.util;

import java.util.List;
import java.util.Map;

import lombok.Data;

// 페이징 관련 정보 + 게시글 정보
@Data
public class ArticlePage<T> {
	//전체글 수
	private int total;
	// 현재 페이지 번호
	private int currentPage;
	// 전체 페이지수 				-> 글 227개 : 10개씩 묶으면 총 28개의 페이지 생성
	private int totalPages;
	
	private int size;
	// 블록의 크기					-> 한번에 보이는 페이지 번호 개수 	ex. < 1, 2, 3 >  - 3개
	private int blockSize = 5;
	// 블록의 시작 페이지 번호			-> ex. 1
	private int startPage;
	//블록의 종료 페이지 번호			-> ex. 3
	private int endPage;	
	//검색어
	private String keyword = "";
	//요청URL
	private String url = "";
	//select 결과 데이터
	private List<T> content;
	//페이징 처리
	private String pagingArea = "";
	
	private String mode = "";
	

	// 생성자 (Constructor)  : 페이징 정보를 생성
	// Shift + Alt + s
	public ArticlePage(int total, int currentPage, int size, String keyword, List<T> content, String mode) {
		this.total = total;
		this.currentPage = currentPage;
		this.size = size;
		this.keyword = keyword;
		this.content = content;
		this.mode = (mode == null) ? "" : mode;
	
	
		//전체글 수가 0이면?
	    if(total==0) {
	       totalPages = 0;//전체 페이지 수
	       startPage = 0;//블록 시작번호
	       endPage = 0; //블록 종료번호
	    }else {//글이 있다면
	       //   전체 페이지 수 = 전체글 수 / 한 화면에 보여질 목록의 행 수
	       //     27(정수)  = 277(정수)/ 10(정수)
	       this.totalPages = total	/ size;	// 매개변수는 this가 안붙는다.
	       
	       // 나머지(7행)가 있다면, 페이지 1 증가
	       if(total % size > 0) {
	    	   this.totalPages++;	// total페이지 추가
	       }
	       
	       // 페이지 블록 시작번호를 구하는 공식
	       //    블록시작번호 =   현재페이지   /       블록크기(5) *        블록크기  + 1
	       this.startPage = currentPage / this.blockSize * this.blockSize + 1;
	       
	       // 현재페이지 % 블록크기 => 0일 때 보정
	       if(currentPage % this.blockSize == 0) {
	    	   this.startPage -= this.blockSize;
	       }
	       
	       
	       // 블록종료번호 = 시작페이지번호 + (블록크기 - 1)
	       // [1][2][3][4][5][다음]
	       this.endPage = this.startPage + (this.blockSize - 1);
	       
	       // 종료블록번호 > 전체페이지수 => 종료블록번호에 전체페이지수로 보정
	       if(this.endPage > this.totalPages) {
	    	   this.endPage = this.totalPages;
	       }
	       
	    }	// end if
	
   }// end ArticlePate

	//근태용 페이지네이션 메서드 오버로딩
	public ArticlePage(int total, int currentPage, int size, String keyword, List<T> content) {
		this.total = total;
		this.currentPage = currentPage;
		this.keyword = keyword;
		this.content = content;


		//전체글 수가 0이면?
		if(total==0) {
			totalPages = 0;//전체 페이지 수
			startPage = 0;//블록 시작번호
			endPage = 0; //블록 종료번호
		}else {//글이 있다면
			//   전체 페이지 수 = 전체글 수 / 한 화면에 보여질 목록의 행 수
			//     27(정수)  = 277(정수)/ 10(정수)
			this.totalPages = total	/ size;	// 매개변수는 this가 안붙는다.

			// 나머지(7행)가 있다면, 페이지 1 증가
			if(total % size > 0) {
				this.totalPages++;	// total페이지 추가
			}

			// 페이지 블록 시작번호를 구하는 공식
			//    블록시작번호 =   현재페이지   /       블록크기(5) *        블록크기  + 1
			this.startPage = currentPage / this.blockSize * this.blockSize + 1;

			// 현재페이지 % 블록크기 => 0일 때 보정
			if(currentPage % this.blockSize == 0) {
				this.startPage -= this.blockSize;
			}


			// 블록종료번호 = 시작페이지번호 + (블록크기 - 1)
			// [1][2][3][4][5][다음]
			this.endPage = this.startPage + (this.blockSize - 1);

			// 종료블록번호 > 전체페이지수 => 종료블록번호에 전체페이지수로 보정
			if(this.endPage > this.totalPages) {
				this.endPage = this.totalPages;
			}

		}	// end if

	}// end ArticlePate

	// ---------------------------------------------------
	
	// [map 추가]
	
	public ArticlePage(int total, int currentPage, int size, String keyword, List<T> content, 
						String mode, Map<String, Object> map) {
		this.total = total;
		this.currentPage = currentPage;
		this.keyword = keyword;
		this.content = content;
		this.mode = mode;
		//(null일 경우 빈 문자열로 대체)
		this.url = (map.get("url") == null) ? "" : map.get("url").toString();
	
	
		//전체글 수가 0이면?
	    if(total==0) {
	       totalPages = 0;//전체 페이지 수
	       startPage = 0;//블록 시작번호
	       endPage = 0; //블록 종료번호
	    }else {//글이 있다면
	       //   전체 페이지 수 = 전체글 수 / 한 화면에 보여질 목록의 행 수
	       //     27(정수)  = 277(정수)/ 10(정수)
	       this.totalPages = total	/ size;	// 매개변수는 this가 안붙는다.
	       
	       // 나머지(7행)가 있다면, 페이지 1 증가
	       if(total % size > 0) {
	    	   this.totalPages++;	// total페이지 추가
	       }
	       
	       // 페이지 블록 시작번호를 구하는 공식
	       //    블록시작번호 =   현재페이지   /       블록크기(5) *        블록크기  + 1
	       this.startPage = currentPage / this.blockSize * this.blockSize + 1;
	       
	       // 현재페이지 % 블록크기 => 0일 때 보정
	       if(currentPage % this.blockSize == 0) {
	    	   this.startPage -= this.blockSize;
	       }
	       
	       
	       // 블록종료번호 = 시작페이지번호 + (블록크기 - 1)
	       // [1][2][3][4][5][다음]
	       this.endPage = this.startPage + (this.blockSize - 1);
	       
	       // 종료블록번호 > 전체페이지수 => 종료블록번호에 전체페이지수로 보정
	       if(this.endPage > this.totalPages) {
	    	   this.endPage = this.totalPages;
	       }
		       
		       
 //---------------- 페이징 블록 처리 시작 ------------------------------------------------
         this.pagingArea += "<div class='row'><div class='col-sm-12 col-md-7'>";
         this.pagingArea += "<div class='dataTables_paginate paging_simple_numbers' id='example2_paginate'><ul class='pagination'>";
         
         String strHide = "";
      // strHide : prev 비활성화
         if(this.startPage < 6) {
            strHide = "disabled";
         }
         
         //					<a href='#' onclick="listFn('/list',2,'title','개똥이')"
         this.pagingArea += "<li class='paginate_button page-item previous "+strHide+"' id='example2_previous'>";
         this.pagingArea += "<a href='#' onclick=\"listFn('"+this.url+"','"+(this.startPage-5)+"','"+mode+"','"+keyword+"')\" aria-controls='example2' data-dt-idx='0' tabindex='0' class='page-link'>Previous</a></li>";
         								// 파라미터로 넘어온 값 : this. 사용 (ex. this.currnetPage)
         
         String str = "";
            // 페이지 번호가 1씩 증가 반복문
            for(int pNo=this.startPage;pNo<=this.endPage;pNo++) {
                // 현재 페이지와 같다면 스타일 변경하는 if문
                String activeAttr = "";
                if(this.currentPage != pNo) {
                    str = "";

                }else{
                    str = "active";
                    activeAttr = "id='currentPagingItem' data-no='" + pNo + "'";
                }
                this.pagingArea += "<li class='paginate_button page-item "+str + "' " + activeAttr + ">";
                this.pagingArea += "<a href='#' onclick=\"listFn('"+this.url+"',"+pNo+",'"+mode+"','"+keyword+"')\" aria-controls='example2' data-dt-idx='"+pNo+"' tabindex='0' class='page-link'>"+pNo+"</a></li>";
            }//end for
         
         String strEHide = "";
         // 총 페이지가 마지막 페이지보다 클때 마지막 페이지 이후의 페이지는 안보이게 설정
         if(this.endPage >= this.totalPages) {
            strEHide = "disabled";
         }
         
         this.pagingArea += "<li class='paginate_button page-item next "+strEHide+"' id='example2_next'>";
         this.pagingArea += "<a href='#' onclick=\"listFn('"+this.url+"',"+(this.startPage+5)+",'"+mode+"','"+keyword+"')\" aria-controls='example2' data-dt-idx='7' tabindex='0' class='page-link'>Next</a></li>";
         
         this.pagingArea += "</ul></div></div></div>";
//-------------- 페이징 블록 처리 끝 --------------------------------------------------------
	       
	    }	// end if
	
   }// end ArticlePate
		
		
/*	
	// 기본생성자
	public ArticlePage() {}


	//getter/setter메서드
	public int getTotal() {
		return total;
	}
	public void setTotal(int total) {
		this.total = total;
	}
	public int getCurrentPage() {
		return currentPage;
	}
	public void setCurrentPage(int currentPage) {
		this.currentPage = currentPage;
	}
	public int getTotalPages() {
		return totalPages;
	}
	public void setTotalPages(int totalPages) {
		this.totalPages = totalPages;
	}
	public int getBlockSize() {
		return blockSize;
	}
	public void setBlockSize(int blockSize) {
		this.blockSize = blockSize;
	}
	public int getStartPage() {
		return startPage;
	}
	public void setStartPage(int startPage) {
		this.startPage = startPage;
	}
	public int getEndPage() {
		return endPage;
	}
	public void setEndPage(int endPage) {
		this.endPage = endPage;
	}
	public String getKeyword() {
		return keyword;
	}
	public void setKeyword(String keyword) {
		this.keyword = keyword;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public List<T> getContent() {
		return content;
	}
	public void setContent(List<T> content) {
		this.content = content;
	}
	public String getPageingArea() {
		return pagingArea;
	}
	public void setPageingArea(String pagingArea) {
		this.pagingArea = pagingArea;
	}
	public String getMode() {
		return mode;
	}
	public void setMode(String mode) {
		this.mode = mode;
	}


	//toString
	@Override
	public String toString() {
		return "ArticlePage [total=" + total + ", currentPage=" + currentPage + ", totalPages=" + totalPages
				+ ", blockSize=" + blockSize + ", startPage=" + startPage + ", endPage=" + endPage + ", keyword="
				+ keyword + ", url=" + url + ", content=" + content + ", pagingArea=" + pagingArea + ", mode=" + mode
				+ "]";
	}
*/	
		
	
}
