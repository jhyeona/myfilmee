<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

 	<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
     
<!DOCTYPE html>

<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
    
    <style>
        body,input,textarea,select,button,table{font-family:'Lucida Sans', 'Lucida Sans Regular', 'Lucida Grande', 'Lucida Sans Unicode', Geneva, Verdana, sans-serif; font-size:12px; color:#333;}
        body,div,h1,h2,h3,h4,h5,h6,ul,ol,li,dl,dt,dd,p,form,fieldset,input,table,tr,th,td{margin:0;padding:0;}
        h1,h2,h3,h4,h5,h6{font-weight:normal;font-size:100%;}
        ul,ol{list-style:none;}
        fieldset,img{border:0; vertical-align:top;}
        address{font-style:normal;}
        p,li,dd{font-size:1em; line-height:1.5em; text-align:justify;}
        a, a:hover,a:active,a:focus,a:visited{color:#333;text-decoration:none;}

        a, a:link, a:visited{
            cursor : pointer;
        }
        #contauner{

        }
        table{
            width: 100%;
            white-space: nowrap;
            border: 2px solid black;

            text-align : center;
        }
        #thead{
            margin-bottom: 10px;
            border-width: 90%;
            border-bottom: 2px solid black ;
        }
        #caption{

            font-size: 16px;
            width: 100%;
            border: 2px solid black;
            margin-bottom: 10px;

        }
        tr{
            width: 100%;
            margin-top: 3px;
        }
    </style>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-migrate/3.3.2/jquery-migrate.min.js"></script>

    <script>
         $(function() {
            console.clear();
            console.debug('jq started..');


            $('#get').click(function(){
                console.log('onclick on #get clicked..');
                

            })
			
          

            $('a.prev, a.next').on('click', function(e) {
                console.debug("onclicked for a.next or a.prev...");
                console.log('\t+ this : ', this);

                //Event??? ?????? ????????? ????????? ??????????????? ??????(?????????)
                e.preventDefault();

                // ?????? ?????????????????? Rvalue???????????? ????????? ????????? ??????
                // (???, form ??????)??? ?????????
                var paginationForm = $('#paginationForm');

                paginationForm.attr('action', '/board/listPerPage');
                paginationForm.attr('method', 'GET');

                paginationForm.find('input[name=currPage]').val($(this).attr('href') );
                //paginationForm?????? name ????????? ?????? currPage??? input????????? ?????????
                //????????? ????????? ?????? ??? href??? ?????? ?????? input ????????? ????????? ????????????.
                paginationForm.find('input[name=amount]').val( '${pageMaker.cri.amount}' );
                paginationForm.find('input[name=pagesPerPage]').val( '${pageMaker.cri.pagesPerPage}' );

                paginationForm.submit();
            });//onclick a.prev, a.next

        });//jq
    </script>
</head>
<body>
 

        
    <div id="container">
        <table>
            <caption id="caption">
                <b>????????????</b>
            </caption>


            <thead id="thead">
                <tr>
                    <th>????????????</th>
                    <th>????????????</th>
                    <th>????????????</th>
                    <th>????????????</th>
                    <th>???????????????</th>
                </tr>
                
            </thead>
                <c:forEach items="${list}" var="complaint">
                    <tr>
                        <th><c:out value="${complaint.compno}"/></th>
                        <th>
                            <a href="/complaint/get?compno=${complaint.compno}">
                                <c:choose>
                                    <c:when test="${complaint.code == 1}">
                                        ????????? ????????????
                                    </c:when>
                                    <c:when test="${complaint.code == 2}">
                                        ???????????? ????????????
                                    </c:when>
                                    <c:when test="${complaint.code == 3}">
                                        ???????????? ????????????
                                    </c:when>
                                    <c:otherwise>
                                        ??????
                                    </c:otherwise>
                                </c:choose>
                            </a>
                        </th>
                        <th><c:out value="${complaint.writer}"/></th>
                        <td><fmt:formatDate pattern="yyyy/MM/dd " value="${complaint.insert_ts}"/></td>
                        <td><fmt:formatDate pattern="yyyy/MM/dd " value="${complaint.check_ts}"/></td>

                    </tr>
                </c:forEach>
                
            <tbody>

            </tbody>
        </table>

        <div id="pagination">
            <form id="paginationForm">
                <!-- ?????? ???????????????, ????????? ?????? ???????????? ?????????, ????????? ?????? 3?????? ?????? ????????????????????? ????????????????????? hidden ????????? ?????? -->
                <input type="hidden" name="currPage">
                <input type="hidden" name="amount">
                <input type="hidden" name="pagesPerPage">
                <!-- hidden ????????? ???????????? ???????????? ????????? value?????? ????????????. -->
                <!-- JQuery??? value??? ?????????. -->

                <ul>
                    <c:if test="${pageMaker.prev}">
                        <li class="prev"><a class="prev" href="${pageMaker.startPage-1}">Prev</a></li>
                    </c:if>

                    <!-- begin~end?????? ????????????, ????????? ???????????? var ????????? ???????????? -->
                    <c:forEach 
                        begin="${pageMaker.startPage}" 
                        end="${pageMaker.endPage}" 
                        var="pageNum">

                        <li class="${pageMaker.cri.currPage == pageNum ? 'currPage' : ''}">
                            <a 
                                class="${pageMaker.cri.currPage == pageNum ? 'currPage' : ''}"
                                href="/board/listPerPage?currPage=${pageNum}&amount=${pageMaker.cri.amount}&pagesPerPage=${pageMaker.cri.pagesPerPage}">
                                ${pageNum}
                            </a>
                        </li>
             
                    </c:forEach>

                    <c:if test="${pageMaker.next}">
                        <li class="next"><a class="next" href="${pageMaker.endPage+1}">Next</a></li>
                    </c:if>
                </ul>
            </form>
            
        </div>
    </div>

    </body>
    </html>