SELECT TOP (1000) [Row_ID]
      ,[Order_ID]
      ,[Order_Date]
      ,[Ship_Date]
      ,[Ship_Mode]
      ,[Customer_ID]
      ,[Customer_Name]
      ,[Segment]
      ,[Country]
      ,[City]
      ,[State]
      ,[Postal_Code]
      ,[Region]
      ,[Product_ID]
      ,[Category]
      ,[Sub_Category]
      ,[Product_Name]
      ,[Sales]
      ,[Quantity]
      ,[Discount]
      ,[Profit]
  FROM [SuperStoreAnalytics].[dbo].[Sample - Superstore]
  

 SELECT COUNT(*) AS TotalRows
FROM [dbo].[Sample - Superstore];


select 
[Product_Name],
[product_id],
sum([Profit]) as profit,
sum([Sales]) as sales,
sum([Profit])/nullif(sum([Sales]),0) as profit_margin
from dbo.[Sample - Superstore]
group by [Product_ID],[Product_Name]
order by 
profit_margin asc


select 
[Product_Name],
[product_id],
sum([Profit]) as profit,
sum([Sales]) as sales,
sum([Profit])/nullif(sum([Sales]),0) as profit_margin
from dbo.[Sample - Superstore]
group by [Product_ID],[Product_Name]
having sum(sales)>1000 and sum(profit)< 0   --  هنا استخدمت هافينج مش وير عشان متنفغش مع اجريجيت فانكشنز والكويري دي ورتني ان في منتجات السيلز بتاعتها كويسه لكن البروفيت قليل وبتخسر
order by 
profit_margin asc


select top(3) * from dbo.[Sample - Superstore]   --هنا ده بيرانك علي مستوي الجدول مش مستوي كل كاتيجوري
order by Sales desc

WITH ProductSales AS
(
    SELECT
        Category,
        [Product_Name],
        SUM(Sales) AS TotalSales               -- هنا استخدمت سي تي اي عشان يبقي عندك حاجه زي التوتال سيلز دي  تعرف تستخدمها في السليكتايه اللي تحتها مثلا اللي هي بتاعت الرانكد
    FROM [dbo].[Sample - Superstore]
    GROUP BY
        Category,
        [Product_Name]
),
RankedProducts AS
(
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY Category
            ORDER BY TotalSales DESC     --عملنا سي تي اي تاني اصلا غشان نقدر نعمل فاريابول برودكت رانك ده ونرانك بيه وكده عرفت اعلي 3 منتجات بيتباعو في كل قسم
        ) AS ProductRank
    FROM ProductSales
)
SELECT *
FROM RankedProducts
WHERE ProductRank <= 3
ORDER BY
    Category,
    ProductRank;



select 
[Customer_Name],
sum([profit]) as profitability,
sum([sales]) as total_sales,
sum([profit])/nullif(sum([sales]),0) as profit_margin
                                                             -- هنا جبتلك العملاء الللي بيشتروا ب اكتر من 5000 وبرغم كده بيحققو بروفيت ب السالب
from dbo.[Sample - Superstore]
group by Customer_Name
having sum([profit]) < 0 and sum([sales]) > 5000
order by profitability asc



SELECT
    Discount,
    COUNT(*) AS NumberOfRows,
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,                                     --السلكتايه دي اثبتت ان لما الديسكاونت يزيد البروفيت بتقل ودي مسءله هننقلها للبايثون هيحلها بشكل اعمق
    SUM(Profit) / NULLIF(SUM(Sales), 0) AS ProfitMargin
FROM [dbo].[Sample - Superstore]
GROUP BY
    Discount
ORDER BY
    Discount;



select 
[region],
sum([sales]) as totalsales , 
sum([profit]) as profitability,
sum([profit])/nullif(sum([sales]),0) as profitmargin   --- دي اعلي ريجونز بتجيب ارباح عندك الويست بتبيع كتير وبتكسب نسبه قريبه من النسبه اللي الساوث بتكسبها مع ان الساوث بيبيع اقل  
from dbo.[Sample - Superstore]
group by Region                                                  --وده ممكن نرجع نحلله بعدين حسب State / Category / Discount / Product.
order by totalsales desc




SELECT
    YEAR([Order_Date]) AS OrderYear,                        --هنا شوفت المبيعات و الربح ونسبه الربح كانت عامله ازاي علي سكوب ال4 سنين
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM dbo.[Sample - Superstore]
GROUP BY YEAR([Order_Date])
ORDER BY OrderYear;



select 
sum([sales]) as totalsales,
sum([profit]) as profitability,
MONTH([order_date]) as orderMonth,                                            --علي سكوب الشهور هتلاقي شهور عماله تطلع وشهور تنزل سيلز مذبذبه ومارجين مذيذب
Year([order_date]) as orderYear,
sum([profit]) / nullif(sum([sales]),0) as profitMargin
from dbo.[Sample - Superstore]
group by Year([order_date]) , MONTH([order_date])
order by Year([order_date]) , MONTH([order_date]) asc



SELECT
    MONTH([Order_Date]) AS OrderMonth,
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,                                         --تحليل للشهور عامتا عشان انا عايز اعرف انا عندي فترات موسميه مثلا عشان نعلي البضاعه في الشهور الموسميه دي او حاجه 
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin               --Profit is not evenly distributed throughout the year. March shows a noticeable increase in profitability, while September through December represent the strongest profit-generating period, with December achieving the highest total profit.
FROM dbo.[Sample - Superstore]                                            --اخر اربع شهور فيهم ارتفاع ملحوظ ف الربح في شهور فوق عاليه برضه 
GROUP BY MONTH([Order_Date])
ORDER BY OrderMonth;




SELECT
    [Customer_ID],
    [Customer_Name],
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,                                      --there are some customers with very close sales amount but a big difference in the profit which means High sales volume does not necessarily translate into high profitability.
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin            --there is a customer that his sales is near to 4346 and profit is 1990 which means his margin is 45% and other customers has sales with 10300 and profit is 1390 which his margin is 13%  so Customer value should not be evaluated using Sales alone.
FROM dbo.[Sample - Superstore]
GROUP BY
    [Customer_ID],
    [Customer_Name]
ORDER BY
    TotalProfit DESC;




SELECT
    [Customer_ID],
    [Customer_Name],                                              --first customer is the highest in sales and his profit with negative what a shame
    SUM([Sales]) AS TotalSales,                                    --Sales alone is not enough to measure customer value.
    SUM([Profit]) AS TotalProfit,                                  -- tamara bought with less sales than him and has a 8981 profit
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM dbo.[Sample - Superstore]
GROUP BY
    [Customer_ID],
    [Customer_Name]
ORDER BY
    TotalSales DESC;




    with customerinfo as
    (
    select 
    Customer_ID,
    Customer_Name,
    sum([profit]) as profitability
    from dbo.[Sample - Superstore]
    group by  Customer_ID,
    Customer_Name                        --الكويري دي اساسا بنعملها عشان نشوف هل في عملاء محددين عندهم تركيز عالي من البروفيت واكلين البروفيت يعني
    )
    select
    Customer_ID,
    Customer_Name,       --احنا هنا عملنا سيلكت للاي دي والنيم تاني لان السيلكت الخارجي هو اللي بيحدد ايه اللي هيبان ف الجدول النهائي
    profitability,       -- احنا عملنا cte عشان يخلينا نستخدم البروفبتابيليتي دي تحت وفوق يعني في مكانين
    sum([profitability]) over() as overallprofit, --دي ويندو فانكشن عشان تجبلك مجموع كل االبروفيت في كل الصقوف وتعرضهملك في خانه واحده اسمها اوفر اول بروفيت
    profitability / NULLIF(SUM([profitability]) OVER (), 0) AS ProfitShare
    from customerinfo
    order by profitability desc        --tamara contributes with 3.13% from overall profit and raymond contributes with 2.43%





    SELECT
    [Customer_ID],
    [Customer_Name],                                              --first customer is the highest in sales and his profit with negative what a shame
    SUM([Sales]) AS TotalSales,                                    --Sales alone is not enough to measure customer value.
    SUM([Profit]) AS TotalProfit,                                  -- tamara bought with less sales than him and has a 8981 profit
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM dbo.[Sample - Superstore]
GROUP BY
    [Customer_ID],
    [Customer_Name]
ORDER BY
    TotalSales DESC;




    with customerinfo as
    (
    select 
    Customer_ID,
    Customer_Name,
    sum([profit]) as profitability
    from dbo.[Sample - Superstore]
    group by  Customer_ID,
    Customer_Name                        
    )
    select
    Customer_ID,
    Customer_Name,       
    profitability,      
    sum([profitability]) over() as overallprofit, 
    profitability / NULLIF(SUM([profitability]) OVER (), 0) AS ProfitShare,
    SUM(profitability) OVER (
        ORDER BY profitability DESC                                --اللي احنا زودناه ده بقي بيخليك تجمع البروفيت شير عند الصف اللي انت واقف عنده وكل الصفوف اللي فوقه يعني مثلا تالت صف هتلاقيك جامع تالت صف والاول والتاني
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW           --وده يعرفك ان مثلا اول اربغ عملاء في البروفيتابيليتي يعني اول اعلي اربع عملاء محققين ارباح هما اصلا محققين ما يقارب 10ف الميه من ارباح الشركه اصلا
    ) / NULLIF(SUM(profitability) OVER (), 0) AS CumulativeProfitShare
                                                                            --business insight : Profitability is relatively distributed across the customer base. The top 20 customers contribute about 25.2% of total profit, while the top 50 contribute about 43.4%, suggesting that overall profit is not heavily dependent on a very small group of customers.
    from customerinfo
    order by profitability desc       




    SELECT
    [Category],
    SUM([Sales]) AS TotalSales,                --نشوف كاتيجوري المنتجات بتحقق ارباح قد ايه
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
    FROM dbo.[Sample - Superstore]                                --business insight : Furniture generates substantial sales but very little profit compared with Technology and Office Supplies.
    GROUP BY [Category]
    ORDER BY TotalProfit DESC;



    SELECT
    [Category],
    [Sub_Category],
    SUM([Sales]) AS TotalSales,                             --لما اخش في الصب كاتيجوري بقي هلاقي ان الفرنتشر مش كل منتجانه خره ده في زي الكرسي ده شغال حلو   انما الترابيزات والبوك كيس دول بيخسرو اصلا
    SUM([Profit]) AS TotalProfit,                           -- لو نزلت بقي علي الماشينز ف قسم التكنولوجيا هتلاقي المارجن بتاعها بتاع حاجه ونص ف الميه ودي حاجه خره ودخ يعرفك ان مش عشان الكاتيجوري حلو يبقي كل الصب كاتدوري حلو
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM dbo.[Sample - Superstore]
GROUP BY
    [Category],
    [Sub_Category]
ORDER BY TotalProfit DESC;



SELECT
    [Category],
    [Sub_Category],
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    AVG([Discount]) AS AvgDiscount,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin     --ليه افردج ديسكاونت مش ديسكاونت بس لان كل اوردر لاين لي الديسكاونت الخاص بي هو مش ثابت علي كل الصب كاتجوري
FROM dbo.[Sample - Superstore]                                  -- والنتيجه موضحه ان مش الديسكاونت بس هو سبب الخساره انت عندك حاجات عليها ديسكاونت كبير وبتخسر وحاجات علبها ديسكاونت قليل وبتكسب
GROUP BY
    [Category],
    [Sub_Category]
ORDER BY
    AvgDiscount DESC;




    SELECT
    [Discount],
    COUNT(*) AS OrderLines,
    SUM([Sales]) AS TotalSales,         -- هنا بقي دخلنا جوه سكوب الترابيزات مش الصب كاتجوري من فوق
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin     --لقينا ان في 72 اوردر معمول من غير خصم والمارجين والمكسب بتاعهم حلو اوي
FROM dbo.[Sample - Superstore]                                  --اول معملنا ديسكاونت المكسب بقي بالسالب ماشاء اللي عرفنا اللي فشخ التراببيزات 
WHERE [Sub_Category] = 'Tables'                                 -- business insight : Higher discount levels are strongly associated with lower profitability in the Tables sub-category.
GROUP BY [Discount]
ORDER BY [Discount];





SELECT
    [Sub_Category],
    [Discount],
    COUNT(*) AS OrderLines,
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,                              --هنلاقي ان معظم الصب كاتجوري الديسكاونت فيهم بيقلل المارجين بس ده مش قران ومش ده السبب الوحيد فا هنكتب انسايت غير مبالغ في
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin    --business insight : Higher discounts are generally associated with declining profit margins, and in several sub-categories high discount levels coincide with negative profitability.
FROM dbo.[Sample - Superstore]
GROUP BY
    [Sub_Category],
    [Discount]
ORDER BY
    [Sub_Category],
    [Discount];




    WITH DiscountGroups AS (
    SELECT
        CASE
            WHEN [Discount] = 0 THEN '0%'
            WHEN [Discount] <= 0.10 THEN '1-10%'
            WHEN [Discount] <= 0.20 THEN '11-20%'
            WHEN [Discount] <= 0.30 THEN '21-30%'
            WHEN [Discount] <= 0.40 THEN '31-40%'
            WHEN [Discount] <= 0.50 THEN '41-50%'
            ELSE '>50%'
        END AS DiscountRange,
                                                                     --هنا بقي اول ما الخصم عدي ال30 ف الميه المكسب بقي ب السالب 
        [Sales],                                                      --business insight : "In this dataset, discount levels of 31% or higher are associated with negative overall profit margins."
        [Profit]
    FROM dbo.[Sample - Superstore]
)

SELECT
    DiscountRange,
    COUNT(*) AS OrderLines,
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM DiscountGroups
GROUP BY DiscountRange
ORDER BY DiscountRange;





WITH DiscountGroups AS (
    SELECT
        [Category],
        [Region],
        CASE
            WHEN [Discount] = 0 THEN '0%'
            WHEN [Discount] <= 0.10 THEN '1-10%'           --business insight :The impact of discounts varies significantly by category and region. Furniture is the most discount-sensitive category, with profitability turning negative at 31–40% discounts in multiple regions, while Technology remains profitable at 21–30% discounts across all regions. Extremely high discounts (>50%) are consistently associated with severe losses across categories.
            WHEN [Discount] <= 0.20 THEN '11-20%'          --
            WHEN [Discount] <= 0.30 THEN '21-30%'
            WHEN [Discount] <= 0.40 THEN '31-40%'
            WHEN [Discount] <= 0.50 THEN '41-50%'
            ELSE '>50%'
        END AS DiscountRange,
        [Sales],
        [Profit]
    FROM dbo.[Sample - Superstore]
)

SELECT
    [Category],
    [Region],
    DiscountRange,
    COUNT(*) AS OrderLines,
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM DiscountGroups
GROUP BY
    [Category],
    [Region],
    DiscountRange
ORDER BY
    [Category],
    [Region],
    DiscountRange;








WITH FurnitureDiscount AS (                 --هنا نخش جوه الفرنتشر بقي عشان نشوف المشكله بوضوح اكتر
    SELECT
        [Sub_Category],                      --تخيل ان البوك كيس ف الويست لما الخصم بيعدي 50 ف الميه بتجيب مكاسب ب سالب 150 ف الميه  دي اذمه دي
        [Region],
        CASE                                    -- بس عندك حاجه حلوه زي الكراسي فضلت تكسب ف كل المناطق لحد ما الخصم بقي من 30 ل 40 ف الميه
            WHEN [Discount] = 0 THEN '0%'         -- عندك الورنيش ده مخسرش خالص غير لما الخصم عدي 50 ف السنترال 
            WHEN [Discount] <= 0.10 THEN '1-10%'
            WHEN [Discount] <= 0.20 THEN '11-20%'   -- فاانت مبتتعاملش مع كل الكاتيجوريز ولا كل الريجونز بنفس الطريقه
            WHEN [Discount] <= 0.30 THEN '21-30%'
            WHEN [Discount] <= 0.40 THEN '31-40%'    --business insight :Furniture is the most discount-sensitive category, with the main profitability issues concentrated in Tables and Bookcases. Both sub-categories are profitable with no discount but become loss-making as discount levels increase across multiple regions. Tables show particularly severe losses at 31–50% discounts, while Bookcases experience extreme losses at higher discount levels.
            WHEN [Discount] <= 0.50 THEN '41-50%'    --business reccomendation :The company should avoid applying a uniform discount strategy across all products. Discount policies should be tailored by sub-category, with stricter limits for Tables and Bookcases, while allowing more flexibility for relatively resilient sub-categories such as Furnishings and Chairs.
            ELSE '>50%'
        END AS DiscountRange,
        [Sales],
        [Profit]
    FROM dbo.[Sample - Superstore]
    WHERE [Category] = 'Furniture'
)
SELECT
    [Sub_Category],
    [Region],
    DiscountRange,
    COUNT(*) AS OrderLines,
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM FurnitureDiscount
GROUP BY
    [Sub_Category],
    [Region],
    DiscountRange
ORDER BY
    [Sub_Category],
    [Region],
    DiscountRange;







    SELECT
    [Ship_Mode],
    COUNT(DISTINCT [Order_ID]) AS TotalOrders,               --مفيش مشكله فعليه ف طريقه التوصيل 
    SUM([Sales]) AS TotalSales,                              --business insight : Standard Class generates the highest sales and profit because it is by far the most widely used shipping method. However, First Class has the highest profit margin at 13.93%, compared with 12.11% for Standard Class.
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM dbo.[Sample - Superstore]
GROUP BY [Ship_Mode]
ORDER BY TotalProfit DESC;




SELECT
    [ship_mode],
    COUNT(DISTINCT [order_id]) AS TotalOrders,
    AVG(DATEDIFF(DAY, [order_date], [ship_date])) AS AvgShippingDays,     --فانكشن ديتد اف دي بتحسب عدد الايام ما بين الحاجتين اللي انت هتديهم ليها اللي هما اوردر ديت وشيب ديت
    MIN(DATEDIFF(DAY, [order_date], [ship_date])) AS MinShippingDays,     --ايام التوصيل مبتعملش فرق ف البروفيت مارجين
    MAX(DATEDIFF(DAY, [order_date], [ship_date])) AS MaxShippingDays      --business insight :Shipping speed varies clearly by shipping mode. Same Day orders are shipped within 0–1 day, First Class averages 2 days, Second Class averages 3 days, while Standard Class takes 5 days on average.Faster shipping does not appear to come with a major profitability penalty in this dataset, as profit margins remain relatively close across shipping modes.
FROM dbo.[Sample - Superstore]
GROUP BY [ship_mode]
ORDER BY AvgShippingDays;








SELECT
    [Category],
    [Sub_Category],
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM dbo.[Sample - Superstore]
GROUP BY
    [Category],
    [Sub_Category]
HAVING SUM([Profit]) < 0            --عرفنا الصب كاتجوري اللي بيخسروا وبيجيبو ارقام ب السالب كا توتال 
ORDER BY TotalProfit;




WITH LossMaking AS (
    SELECT
        [Category],
        [Sub_Category],
        SUM([Sales]) AS TotalSales,
        SUM([Profit]) AS TotalProfit
    FROM dbo.[Sample - Superstore]
    GROUP BY
        [Category],
        [Sub_Category]
    HAVING SUM([Profit]) < 0
)
SELECT
    [Category],
    [Sub_Category],
    TotalSales,
    TotalProfit,
    ABS(TotalProfit) / NULLIF(              --ABS القيمه المطلقه دي بتشيل السالب
        SUM(ABS(TotalProfit)) OVER (),    
        0
    ) AS LossShare             --LOSS SHARE نسبه مئويه للخساره المسببه
FROM LossMaking                --BUSINESS INSIGHT : Tables account for 78.8% of the total losses among loss-making sub-categories, making them the primary profitability problem. Together, Tables and Bookcases account for 94.6% of total losses, indicating that profitability issues are highly concentrated in a small number of sub-categories.
ORDER BY TotalProfit;





SELECT
     [category],
    [sub_category],
    [Product_ID],
    [Product_Name],
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin     --products that earns alot 
FROM dbo.[Sample - Superstore]
GROUP BY
    [Product_ID],
    [Product_Name]
ORDER BY TotalProfit DESC;





SELECT
    [category],
    [sub_category],
    [Product_ID],
    [Product_Name],
    SUM([Sales]) AS TotalSales,
    SUM([Profit]) AS TotalProfit,
    SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
FROM dbo.[Sample - Superstore]
GROUP BY
    [Product_ID],
    [Product_Name],      --عندنا اول 3 منتجات اصلا بيخسرو كتير فشخ مع انهم من قسم التكنولوجيا مش الاثاث حتي
    [category],          -- business insight :Category-level performance can hide serious problems at the individual-product level.
    [sub_category]        --هتلاقي منتجات المارجن بتااعتها زي الخره بس السيلز بتاعتها قليله فشخ اصلا فا مش فارقه انما في منتجات تانيه سيلز عاليه ومارجين قليل اوي ب السالب دي بقي مشاكل حقيقيه 
HAVING SUM([Profit]) < 0
ORDER BY TotalProfit;





WITH LossMakingProducts AS (
    SELECT
        [category],
        [sub_category],
        [Product_ID],
        [Product_Name],
        SUM([Sales]) AS TotalSales,
        SUM([Profit]) AS TotalProfit
    FROM dbo.[Sample - Superstore]
    GROUP BY
        [category],
        [sub_category],
        [Product_ID],
        [Product_Name]
    HAVING SUM([Profit]) < 0
)
SELECT
    [category],
    [sub_category],
    [Product_ID],
    [Product_Name],
    TotalSales,
    TotalProfit,
    ABS(TotalProfit) / NULLIF(                       --اول 3 منتجات هما 23 ف الميه من اجمالي خساره المنتجات كلها اول واحد 11 ف الميه بعده خمسه بعده خمسه
        SUM(ABS(TotalProfit)) OVER (),               --بس في عدد كبير من المنجات فيها لوس شير صغير فا لازم تفهم ان المشكله مش ف 3 منتجات بس
        0                                            --business insight :There are a few major loss-making products, but the overall product-level losses are also widespread across many products.
    ) AS LossShare                                   --وفاكر لما طلعنا ان التكنولوجي قسم ناجح وبيعمل بروفيت 17 ف الميه بص تحت كده هتلاقي عنده منتجات بتخسر جدا
FROM LossMakingProducts                                --وده يعلمنا Category-level profitability can hide serious problems at the product level.
ORDER BY TotalProfit;                                  --business insight : Product-level analysis reveals that losses are both concentrated and widespread. The three largest loss-making products account for approximately 22.5% of total losses among loss-making products, while many additional products contribute smaller losses. Technology, despite being the most profitable category overall, contains several high-impact loss-making products, while Furniture Tables show a broader structural profitability problem across multiple products.






  
       
                                           --في منتجات السيلز بتاعتها عاليه جدا وخسارتها كبيره دي مشكله وتستحق التحقيق
                               --في منتجات مبيعاتها قليله و خسارتها قليله دي تاثيرها علي البيزنس اقل
                      --الثريثهولد اللي هو 10000 اللي مستخدمينه ده مجرد رقم ممكن ميبقاش صحيح كا بيزنس وايز
      
                           --مثلا عندك اخر منتج خالص ف الكويري مطلع ان الكزسي ده هاي سيلز هاي ريسك لانه بيبيع اكتر من 20 الف والبروفيت بتاعته ب السالب بس لو جيت بصيت ع البروفيت بقي هتلاقيها 0.0000001سالب يعني صفر اصلا
                                                 --فا الكرسي ده مش ريسك عالي اساسا مقارنه ب الباقي
  
   

   



    
WITH ProductPerformance AS
(
    SELECT
        [Product_ID],                              --هنا صنفت المنتجات لحاجات بتخسر وحاجات بريك ايفين يعني بتخسر بنسبه اقل من واحد ف الميه اصلا وحاجات بتكسب
        [Product_Name],
        [Category],
        [Sub_Category],

        SUM([Sales]) AS TotalSales,
        SUM([Profit]) AS TotalProfit,

        SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin

    FROM dbo.[Sample - Superstore]

    GROUP BY
        [Product_ID],
        [Product_Name],
        [Category],
        [Sub_Category]
),

ProductClassification AS
(
    SELECT
        *,
        
        CASE
            WHEN ABS(TotalProfit) < 0.01
                THEN 'Break-even'

            WHEN TotalProfit < 0
                THEN 'Loss'

            ELSE 'Profitable'
        END AS ProfitStatus

    FROM ProductPerformance
)

SELECT *
FROM ProductClassification
ORDER BY
    TotalProfit ASC;








    WITH ProductPerformance AS
(
    SELECT
        [Product_ID],
        [Product_Name],                                        --we used rank funtion to find out that when the rank gets smaller it means the problem gets bigger either in margin or total sales and what about the first product it has very low rank in margin and sales so its a big problem product
        [Category],
        [Sub_Category],
        SUM([Sales]) AS TotalSales,
        SUM([Profit]) AS TotalProfit,
        SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
    FROM dbo.[Sample - Superstore]
    GROUP BY
        [Product_ID],
        [Product_Name],
        [Category],
        [Sub_Category]
),

LossProducts AS
(
    SELECT *
    FROM ProductPerformance
    WHERE TotalProfit < -0.01
),

RankedLossProducts AS
(
    SELECT
        *,
        RANK() OVER (ORDER BY TotalProfit ASC) AS LossRank,
        RANK() OVER (ORDER BY ProfitMargin ASC) AS MarginRank
    FROM LossProducts
)

SELECT *
FROM RankedLossProducts
ORDER BY LossRank ;








WITH ProductPerformance AS
(
    SELECT
        [Product_ID],
        [Product_Name],
        [Category],
        [Sub_Category],
        SUM([Sales]) AS TotalSales,
        SUM([Profit]) AS TotalProfit,
        SUM([Profit]) / NULLIF(SUM([Sales]), 0) AS ProfitMargin
    FROM dbo.[Sample - Superstore]
    GROUP BY
        [Product_ID],
        [Product_Name],
        [Category],
        [Sub_Category]
),

LossProducts AS
(
    SELECT
        *,
        -TotalProfit AS LossAmount
    FROM ProductPerformance
    WHERE TotalProfit < -0.01
),

Thresholds AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY LossAmount)
            OVER () AS HighLossThreshold,

        PERCENTILE_CONT(0.90)
            WITHIN GROUP (ORDER BY LossAmount)
            OVER () AS CriticalLossThreshold,

        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY ProfitMargin)
            OVER () AS SevereMarginThreshold
    FROM LossProducts
)

SELECT
    L.[Product_ID],
    L.[Product_Name],
    L.[Category],
    L.[Sub_Category],
    L.TotalSales,
    L.TotalProfit,
    L.LossAmount,
    L.ProfitMargin,

    CASE
        WHEN L.LossAmount >= T.CriticalLossThreshold
             AND L.ProfitMargin <= T.SevereMarginThreshold
            THEN 'Critical'

        WHEN L.LossAmount >= T.HighLossThreshold
            THEN 'High Financial Impact'

        WHEN L.ProfitMargin <= T.SevereMarginThreshold
            THEN 'Severe Margin Problem'

        ELSE 'Low Priority'
    END AS ActionPriority

FROM LossProducts L
CROSS JOIN Thresholds T

ORDER BY
    L.LossAmount DESC;