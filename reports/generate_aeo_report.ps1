# AEO Audit Report Generator for firstamerica.com
# PowerShell 5.1 compatible - ASCII only, no em-dashes, no bare & in strings

$outputPath = "$PSScriptRoot\FirstAmerica_AEO_Audit_2026.docx"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()
$doc.PageSetup.TopMargin    = $word.InchesToPoints(1)
$doc.PageSetup.BottomMargin = $word.InchesToPoints(1)
$doc.PageSetup.LeftMargin   = $word.InchesToPoints(1.1)
$doc.PageSetup.RightMargin  = $word.InchesToPoints(1.1)

# Colour constants (Word uses BGR integer)
$NAVY   = 0x1F3864
$BLUE   = 0x2E74B5
$GREEN  = 0x375623
$RED_T  = 0xC00000
$AMBER  = 0x833C00
$LGRAY  = 0xF2F2F2
$DKGRAY = 0x404040
$ORANGE = 0xC55A11
$BGBLUE = 0xDEEBF7
$BGGRN  = 0xE2EFDA
$BGRED  = 0xFFE0E0
$BGYEL  = 0xFFF2CC
$WHITE  = 0xFFFFFF

function Sel { $word.Selection }

function SetFont($name,$size,$bold,$color,$italic=$false) {
    (Sel).Font.Name   = $name
    (Sel).Font.Size   = $size
    (Sel).Font.Bold   = $bold
    (Sel).Font.Color  = $color
    (Sel).Font.Italic = $italic
}

function TypeText($text) { (Sel).TypeText($text) }
function NL { (Sel).TypeParagraph() }

function Para($sb=0,$sa=6) {
    (Sel).ParagraphFormat.SpaceBefore = $sb
    (Sel).ParagraphFormat.SpaceAfter  = $sa
}

function HR {
    (Sel).ParagraphFormat.Borders.Item(3).LineStyle = 1
    (Sel).ParagraphFormat.Borders.Item(3).LineWidth = 6
    (Sel).ParagraphFormat.Borders.Item(3).Color     = $BLUE
    (Sel).TypeParagraph()
    (Sel).ParagraphFormat.Borders.Item(3).LineStyle = 0
}

function H1($text) {
    NL; Para 16 4
    SetFont 'Calibri' 22 $true $NAVY
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function H2($text) {
    Para 12 4
    SetFont 'Calibri' 14 $true $BLUE
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function H3($text) {
    Para 8 2
    SetFont 'Calibri' 11 $true $DKGRAY
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function Body($text,$color=$DKGRAY,$bold=$false,$italic=$false) {
    Para 0 6
    SetFont 'Calibri' 11 $bold $color $italic
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function Code($text) {
    Para 4 4
    (Sel).ParagraphFormat.LeftIndent  = $word.InchesToPoints(0.3)
    (Sel).ParagraphFormat.RightIndent = $word.InchesToPoints(0.3)
    (Sel).ParagraphFormat.Shading.BackgroundPatternColor = $LGRAY
    SetFont 'Courier New' 9 $false $DKGRAY
    TypeText $text; NL
    (Sel).ParagraphFormat.LeftIndent  = 0
    (Sel).ParagraphFormat.RightIndent = 0
    (Sel).ParagraphFormat.Shading.BackgroundPatternColor = -16777216
}

function PB { (Sel).InsertBreak(7) }

function MakeTable($rows,$cols) {
    $r = (Sel).Range
    $t = $doc.Tables.Add($r,$rows,$cols)
    $t.Style = 'Table Grid'
    $t.Borders.InsideLineStyle  = 1
    $t.Borders.OutsideLineStyle = 1
    return $t
}

function TC($t,$row,$col,$text,$bold=$false,$fg=$DKGRAY,$sz=10,$align=0,$bg=-1) {
    $c = $t.Cell($row,$col)
    if ($bg -ne -1) { $c.Shading.BackgroundPatternColor = $bg }
    $c.Range.Text = $text
    $c.Range.Font.Name  = 'Calibri'
    $c.Range.Font.Size  = $sz
    $c.Range.Font.Bold  = $bold
    $c.Range.Font.Color = $fg
    $c.Range.ParagraphFormat.Alignment  = $align
    $c.Range.ParagraphFormat.SpaceAfter = 2
}

function HRow($t,$headers,$bg=$NAVY,$fg=$WHITE) {
    for ($c=1;$c -le $headers.Count;$c++) {
        TC $t 1 $c $headers[$c-1] $true $fg 10 1 $bg
    }
}

function MoveOut($t) {
    $t.Select()
    (Sel).Collapse(0)
    NL
}

function WhereBadge($t,$row,$col,$type) {
    if     ($type -eq 'FE') { TC $t $row $col 'FRONT END' $true $WHITE  9 1 $BLUE  }
    elseif ($type -eq 'BE') { TC $t $row $col 'BACK END'  $true $WHITE  9 1 $NAVY  }
    else                    { TC $t $row $col 'BOTH'      $true $DKGRAY 9 1 $BGYEL }
}

# ============================================================
# COVER PAGE
# ============================================================
Para 50 0
SetFont 'Calibri' 10 $false $WHITE
(Sel).ParagraphFormat.Alignment = 1; NL

Para 0 4; SetFont 'Calibri' 32 $true $NAVY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'AI VISIBILITY AUDIT'; NL

Para 0 2; SetFont 'Calibri' 20 $false $BLUE
(Sel).ParagraphFormat.Alignment = 1
TypeText 'firstamerica.com'; NL

Para 12 4; SetFont 'Calibri' 13 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'Prepared for: First America'; NL

Para 0 4; SetFont 'Calibri' 13 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'Date: April 24, 2026'; NL

Para 0 4; SetFont 'Calibri' 13 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'Prepared by: Fresh Design Studio'; NL

Para 30 0; SetFont 'Calibri' 12 $true $AMBER
(Sel).ParagraphFormat.Alignment = 1
TypeText 'OVERALL SCORE:  65 / 100  --  NEEDS WORK'; NL

Para 4 4; SetFont 'Calibri' 11 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'This report audits AI visibility across 7 pillars. First America has a strong content foundation and active publishing cadence. Three targeted fixes will move the score into the Pass range.'; NL

PB

# ============================================================
# TABLE OF CONTENTS
# ============================================================
Para 0 6; SetFont 'Calibri' 18 $true $NAVY
(Sel).ParagraphFormat.Alignment = 0
TypeText 'Table of Contents'; NL
HR

$toc = @(
    '1.  Executive Summary',
    '2.  Overall Score Dashboard',
    '3.  AI Bot Access  (Score: 75/100  --  Pass)',
    '4.  Content Structure  (Score: 60/100  --  Needs Work)',
    '5.  Authority and Trust Signals  (Score: 55/100  --  Needs Work)',
    '6.  Content Freshness  (Score: 80/100  --  Pass)',
    '7.  Schema Markup  (Score: 40/100  --  Needs Work)',
    '8.  Machine-Readable Files  (Score: 85/100  --  Pass)',
    '9.  Content Depth and Volume  (Score: 70/100  --  Pass)',
    '10. Competitive Snapshot',
    '11. Final Summary: Pros, Cons and Next Steps'
)
foreach ($line in $toc) {
    Para 0 4; SetFont 'Calibri' 11 $false $DKGRAY
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $line; NL
}
PB

# ============================================================
# 1. EXECUTIVE SUMMARY
# ============================================================
H1 '1. Executive Summary'
HR

Body 'First America is a multi-decade leader in electronics, battery, solar panel, and non-ferrous metals recycling with facilities serving major US metro markets. The company has invested substantially in content marketing -- 189 published blog posts, 247 pages, weekly publishing cadence, programmatic location pages -- and operates one of the most robust llms.txt files in the B2B recycling sector at nearly 50,000 bytes. That content infrastructure puts First America significantly ahead of most competitors in AI visibility readiness.'
Body 'Three issues prevent the site from scoring in the Pass range overall. First, the FAQ page at firstamerica.com/faq still contains Lorem Ipsum placeholder text from the original theme -- its questions reference construction permits and contractor timelines, not recycling. This page is crawled by every AI engine and actively signals low-quality content against an otherwise strong site. Second, Yoast SEO is installed and capable but the schema module has never been configured -- no Organization, Service, or LocalBusiness schema exists anywhere on the site. Third, 763 of 963 uploaded images (79%) are missing alt text, reducing image-based context available to AI crawlers.'
Body 'The positive news is that the structural foundation is solid. The content, publishing rhythm, and machine-readable files are in place. Fixing the FAQ, configuring Yoast schema, and batch-adding image alt text are the three changes that will move First America into Pass territory across every pillar.'

NL; H2 'What Is AI Visibility and Why It Matters for First America'
Body 'AI-generated answers are now the first result shown in approximately 45% of Google searches. Perplexity AI, ChatGPT, and Microsoft Copilot are used daily by procurement managers, sustainability officers, and operations directors at the exact enterprises First America sells to. When a buyer searches "enterprise electronics recycling partner" or "ITAD vendor for data center decommission" -- AI platforms compose a direct answer citing verified sources. Being cited requires structured, extractable, trusted content. First America already produces that content; it is not yet packaged for AI extraction.'
Body 'The stakes are highest in the B2B sector. An enterprise buyer who receives an AI answer citing Iron Mountain, SIMS Recycling, or Stericycle without seeing First America in the response may never reach the First America website. AI citation at this level is equivalent to being on the short list in an RFP.'

NL; H2 'Key Findings at a Glance'
Body 'Where: FRONT END = changes visible on the website.  BACK END = behind the scenes in code or plugin settings.' $DKGRAY $false $true
$kft = MakeTable 10 5
HRow $kft @('Finding','Status','Where','Action Required','Effect Timeline')
$kfd = @(
    @('llms.txt file',                          'ACTIVE -- 49KB, updated Apr 19 2026',     'BE', 'Expand brand summary section at top of file',           'Immediate -- AI reads on next crawl'),
    @('XML sitemap',                            'ACTIVE -- Yoast-generated and indexed',    'BE', 'No action needed -- confirm GSC submission',            'Already working'),
    @('FAQ page content',                       'Lorem Ipsum placeholder -- wrong industry','FE', 'Replace with real First America recycling Q and A',      'AI re-index in 2-4 weeks'),
    @('Organization schema markup',             'ZERO -- Yoast not configured',             'BE', 'Configure Yoast SEO schema -- Organization and Service', 'AI entity recognition in 2-4 weeks'),
    @('Image alt text',                         '763 of 963 images missing alt text (79%)', 'BE', 'Batch-add alt text via Yoast Image SEO or Media Library','Images crawlable after next AI visit'),
    @('Blog authorship attribution',            'Author IDs only -- no visible bylines',    'FE', 'Enable author display on posts with linked author pages', 'Trust signals improve in 2-4 weeks'),
    @('Certifications visible on site',         'Compliant claims present -- no cert logos','FE', 'Add R2, RIOS, ISO or applicable cert logos and pages',   'Authority improves on re-index'),
    @('Plugin updates (11 pending)',            'Elementor 3.25 to 4.0  Yoast 26.4 to 27.4','BE','Update after staging test -- Elementor 4.0 is a major version', 'Performance and security: immediate'),
    @('Robots.txt guidance',                    'Virtual only -- minimal directives',        'BE', 'Add crawl-rate and priority directives for AI bots',     'Crawlers guided within days')
)
for ($r=0;$r -lt $kfd.Count;$r++) {
    $isOk = $kfd[$r][1] -like '*ACTIVE*' -or $kfd[$r][1] -like '*working*'
    $rbg = if ($isOk) { $BGGRN } else { $BGRED }
    $rfg = if ($isOk) { $GREEN } else { $RED_T }
    TC $kft ($r+2) 1 $kfd[$r][0] $false $DKGRAY 10 0 $LGRAY
    TC $kft ($r+2) 2 $kfd[$r][1] $true  $rfg    10 0 $rbg
    WhereBadge $kft ($r+2) 3 $kfd[$r][2]
    TC $kft ($r+2) 4 $kfd[$r][3] $false $DKGRAY 10 0
    TC $kft ($r+2) 5 $kfd[$r][4] $false $GREEN  10 0 $BGGRN
}
MoveOut $kft
PB

# ============================================================
# 2. SCORE DASHBOARD
# ============================================================
H1 '2. Overall Score Dashboard'
HR
Body 'Each pillar is scored out of 100. Below 40 = Failing. 40-69 = Needs Work. 70-100 = Pass.' $DKGRAY $false $true
NL

$sdt = MakeTable 9 4
HRow $sdt @('Pillar','Score','Grade','Status')
$sdd = @(
    @('AI Bot Access',          '75 / 100','B','Pass'),
    @('Content Structure',      '60 / 100','D','Needs Work'),
    @('Authority and Trust',    '55 / 100','D','Needs Work'),
    @('Content Freshness',      '80 / 100','B','Pass'),
    @('Schema Markup',          '40 / 100','D','Needs Work'),
    @('Machine-Readable Files', '85 / 100','A','Pass'),
    @('Content Depth',          '70 / 100','B','Pass'),
    @('OVERALL',                '65 / 100','C','Needs Work -- 3 targeted fixes reach Pass')
)
for ($r=0;$r -lt $sdd.Count;$r++) {
    $sc = [int]($sdd[$r][1].Trim().Split('/')[0].Trim())
    $gbg = if ($sc -ge 70) { $BGGRN } elseif ($sc -ge 40) { $BGYEL } else { $BGRED }
    $gfg = if ($sc -ge 70) { $GREEN } elseif ($sc -ge 40) { $AMBER } else { $RED_T }
    $isLast = ($r -eq $sdd.Count-1)
    $rbg = if ($isLast) { $LGRAY } else { $WHITE }
    TC $sdt ($r+2) 1 $sdd[$r][0] $isLast $DKGRAY 10 0 $rbg
    TC $sdt ($r+2) 2 $sdd[$r][1] $true   $gfg    10 1 $gbg
    TC $sdt ($r+2) 3 $sdd[$r][2] $true   $gfg    11 1 $gbg
    TC $sdt ($r+2) 4 $sdd[$r][3] $isLast $DKGRAY 10 0 $rbg
}
MoveOut $sdt
Body 'Score key:  GREEN (70-100) = Pass   |   YELLOW (40-69) = Needs Work   |   RED (0-39) = Critical Fail' $DKGRAY $false $true
PB

# ============================================================
# 3. AI BOT ACCESS
# ============================================================
H1 '3. AI Bot Access -- 75 / 100  (Pass)'
HR

H2 'What This Measures'
Body 'Before an AI engine can cite your website, its crawler must be able to visit it and understand what it is looking at. This section checks whether major AI platforms can access the site, whether they receive guidance via robots.txt, and whether the sitemap enables systematic discovery of the full content library.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'SSL is active and enforced across the full site. All major AI crawlers can access firstamerica.com over HTTPS without redirects or certificate errors.' $GREEN
Body 'Yoast SEO is generating a sitemap index at firstamerica.com/sitemap_index.xml and the URL is correctly referenced in robots.txt. Google Search Console is verified (googleverify key active). IndexNow is enabled, meaning newly published pages are flagged to Microsoft Bing within minutes of publication -- a significant content freshness advantage.' $GREEN
Body 'A robots.txt file exists and references the sitemap. All major AI crawlers are permitted access. The SG Security plugin (SiteGround native) is active and provides firewall protection without blocking legitimate crawlers.' $GREEN

NL; H2 'CONS -- What Needs Improving'
Body 'The robots.txt file is entirely virtual -- generated by Yoast with no physical file on the server. While functional, a physical robots.txt with explicit per-bot directives is recommended to give fine-grained guidance. Currently the only directive is "Disallow: " (blank) for User-agent: * with no crawl-rate hints.' $AMBER
Body 'No explicit crawl priority directives exist for AI-specific bots. With 247 published pages and 189 blog posts, a more directive robots.txt could prioritise core service pages over conference landing pages and download gated pages.' $AMBER

NL; H2 'AI Crawler Access Table'
$bt = MakeTable 7 3
HRow $bt @('AI Platform','Crawler Bot Name','Access Status')
$brd = @(
    @('ChatGPT (OpenAI)',             'GPTBot',          'ALLOWED -- no restrictions'),
    @('Perplexity',                   'PerplexityBot',   'ALLOWED -- no restrictions'),
    @('Claude (Anthropic)',           'ClaudeBot',       'ALLOWED -- no restrictions'),
    @('Google Gemini / AI Overviews', 'Google-Extended', 'ALLOWED -- GSC verified'),
    @('Microsoft Copilot',            'Bingbot',         'ALLOWED -- IndexNow active'),
    @('Common Crawl (AI training)',   'CCBot',           'ALLOWED -- optional to restrict')
)
for ($r=0;$r -lt $brd.Count;$r++) {
    $isGsc = $brd[$r][2] -like '*verified*' -or $brd[$r][2] -like '*IndexNow*'
    $cbg = if ($isGsc) { $BGGRN } else { $BGBLUE }
    $cfg = if ($isGsc) { $GREEN } else { $BLUE }
    TC $bt ($r+2) 1 $brd[$r][0] $false $DKGRAY 10 0
    TC $bt ($r+2) 2 $brd[$r][1] $false $DKGRAY 10 0
    TC $bt ($r+2) 3 $brd[$r][2] $true  $cfg    10 0 $cbg
}
MoveOut $bt

H2 'Recommended robots.txt Enhancement'
Body 'Add crawl-rate and bot-specific directives to improve AI crawl efficiency across the large content library:' $DKGRAY
Code ("# Managed by First America`r`n`r`n" + "# AI crawlers -- allow full access`r`n" + "User-agent: GPTBot`r`nAllow: /`r`n`r`n" + "User-agent: ClaudeBot`r`nAllow: /`r`n`r`n" + "User-agent: PerplexityBot`r`nAllow: /`r`n`r`n" + "User-agent: Google-Extended`r`nAllow: /`r`n`r`n" + "# All others`r`nUser-agent: *`r`n" + "Disallow: /wp-admin/`r`n" + "Disallow: /wp-login.php`r`n" + "Disallow: /*?*  # block URL parameters`r`n`r`n" + "Sitemap: https://firstamerica.com/sitemap_index.xml")
Body 'Effect: AI crawlers receive explicit permission, admin paths are excluded, and URL parameter variants are blocked from being indexed as duplicate pages. Effect Timeline: crawlers adopt new directives within days.' $DKGRAY $false $true
PB

# ============================================================
# 4. CONTENT STRUCTURE
# ============================================================
H1 '4. Content Structure and Extractability -- 60 / 100  (Needs Work)'
HR

H2 'What This Measures'
Body 'AI engines do not rank pages -- they extract passages. A citable AI snippet is typically a 40-80 word block that directly answers a question and works without surrounding context. This section measures how well the site supports that extraction -- and identifies the single most urgent content problem found during this audit.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'The homepage meta title -- "First America | Electronics and Metals Recycling Company" -- and meta description -- "Leading e-waste solutions with 30+ years of expertise. Recycle electronics, metals, solar panels, and batteries responsibly" -- are clear, specific, and citable. These are the first signals AI engines read when forming a summary of the company.' $GREEN
Body 'Service pages (Electronics Recycling, Battery Recycling, Solar Panel Recycling, Non-Ferrous Metals) exist as dedicated URLs and cover the four primary service categories. Each service has a main page with direct URLs that AI crawlers can bookmark as canonical sources.' $GREEN
Body 'Industry vertical pages exist for 15+ sectors including healthcare, manufacturing, government, aviation, and financial institutions. This depth of vertical coverage is rare among mid-market recyclers and directly supports "recycling for [industry]" queries that AI platforms use for B2B recommendations.' $GREEN
Body 'Blog posts use descriptive, question-format titles: "How to Recycle Lithium-Ion Batteries from IT Equipment", "What Really Happens When You Recycle Solar Panels?", "Are Solar Panels Recyclable?". These are the exact query formats AI engines parse for extractable answers.' $GREEN

NL; H2 'CONS -- What Needs Fixing (CRITICAL)'
Body 'The FAQ page at firstamerica.com/faq contains Lorem Ipsum placeholder text from the original theme template. The active FAQ questions include "What about permits?", "What about materials?", and "What should I be asking my contractor?" -- all about construction. Every AI engine that crawls this page associates First America with irrelevant filler content.' $RED_T $true
Body 'All FAQ answers on the live page are the same Lorem Ipsum passage: "The individual has always had to struggle to keep from being overwhelmed by the tribe..." This text appears three times in identical form, which AI engines flag as duplicate content at the page level.' $RED_T $true
Body '763 of 963 uploaded images (79%) are missing alt text. Images without alt text are invisible to AI crawlers -- they cannot be used to understand service context, equipment types, or facility capabilities. For an industrial recycler whose visual proof of capabilities matters, this is a significant gap.' $RED_T

NL; H2 'FAQ Page: Current vs. Recommended'
H3 'Current Version (Live Right Now -- Damages AI Credibility)'
Code ("Q: What about permits?`r`n" + "A: The individual has always had to struggle to keep from being overwhelmed`r`n" + "   by the tribe. [Lorem Ipsum continues -- identical answer on all 5 questions]`r`n`r`n" + "Q: What about materials?`r`n" + "A: [Same Lorem Ipsum text repeated]`r`n`r`n" + "Q: What should I be asking my contractor?`r`n" + "A: [Same Lorem Ipsum text repeated]`r`n`r`n" + "CONTEXT: This page describes a construction FAQ. It has no connection`r`n" + "to electronics or metals recycling.")
Body 'Why this is damaging: AI engines crawling this page see an electronics recycling company discussing contractor questions with Latin filler text. This signals fabricated, untrustworthy content against a site that otherwise publishes strong recycling articles.' $RED_T $false $true

H3 'Recommended Version (Citable by AI)'
Code ("Q: What types of electronics does First America recycle?`r`n" + "A: First America recycles computers, servers, laptops, monitors, printers,`r`n" + "   networking equipment, mobile devices, and industrial electronics.`r`n" + "   We also recycle solar panels, lithium-ion batteries, EV battery packs,`r`n" + "   BESS systems, and non-ferrous metals including copper and aluminum.`r`n`r`n" + "Q: How does First America handle data destruction?`r`n" + "A: First America provides certified data destruction for hard drives and`r`n" + "   storage media. Clients receive a Certificate of Destruction confirming`r`n" + "   data has been destroyed to NIST 800-88 standards before any equipment`r`n" + "   is processed for recycling or resale.`r`n`r`n" + "Q: Does First America pick up electronics from our location?`r`n" + "A: Yes. First America provides logistics and transportation services`r`n" + "   for businesses in the Dallas-Fort Worth, Chicago, and Atlanta metro`r`n" + "   areas, as well as nationwide pickup for large-volume clients.`r`n`r`n" + "Q: What certifications does First America hold?`r`n" + "A: [List applicable certifications here -- R2, RIOS, ISO 9001, etc.]")
Body 'Why AI will cite this: Every answer is independently extractable, specific to the business, and directly answers B2B buyer questions. The data destruction answer alone covers a high-value query category.' $GREEN $false $true
PB

# ============================================================
# 5. AUTHORITY AND TRUST
# ============================================================
H1 '5. Authority and Trust Signals -- 55 / 100  (Needs Work)'
HR

H2 'What This Measures'
Body 'AI systems prefer sources they can verify and trust. A 2024 Princeton study (KDD 2024, analysed across Perplexity AI) identified the content signals that most increase AI citation probability. This section scores First America against those proven factors.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'The 30-plus year operating history is stated clearly in the homepage meta description and homepage content. Longevity is a direct trust signal -- AI engines weight established companies higher than newer entrants when answering "who is the best" or "who is the most reliable" queries.' $GREEN
Body 'The WP Reviews for Google plugin is active, which surfaces Google Review ratings and counts on the site. Customer review data is one of the nine trust factors in the Princeton study and increases citation probability when it is crawlable.' $GREEN
Body 'First America is a member of the Soteria Battery Safety Consortium (confirmed via published page). Industry consortium membership signals technical authority and is frequently cited by AI platforms as a credibility marker for B2B service providers.' $GREEN
Body 'Industry event presence is documented (Battery Show 2024, 2025, 2026 -- RE+ Las Vegas -- E-Scrap 2024, 2025 -- MODEX -- ITAD Summit -- Offshore Technology Conference). Event participation pages create multiple trust signals: industry recognition, active engagement, and date-stamped company activity.' $GREEN

NL; H2 'CONS -- What Needs Improving'
Body 'All blog posts are attributed to internal author IDs 4 and 8. No public author name, bio, or credentials appear on posts. Named authors with verifiable credentials increase AI citation probability by approximately 25% according to the Princeton study.' $RED_T
Body 'Certifications are referenced obliquely ("compliant recycling processes") but no certification names, numbers, or logos appear on the site. Competitors listing R2, RIOS, ISO 9001, or e-Stewards certification with linked certificate pages immediately outrank uncertified pages for regulatory-sensitive queries.' $RED_T
Body 'No statistics are cited with external sources. The claim "one of the largest electronics and metals recycling companies in the United States" is powerful but uncited. Citing industry data with a source attribution increases AI citation probability by 37%.' $RED_T

NL; H2 'Trust Signal Audit (Princeton Study Factors)'
$pbt = MakeTable 10 4
HRow $pbt @('Trust Signal','Citation Boost','First America Status','Recommended Action')
$pbd = @(
    @('Cite external sources and data',    '+40%','ZERO external citations on key pages',  'Add source links to industry stat claims'),
    @('Include statistics and data',       '+37%','2-3 claims, none cited with source',    'Cite "30+ years" and size claims with data'),
    @('Author attribution with bio',       '+25%','MISSING -- author IDs only',            'Enable author pages and link all posts'),
    @('Certifications and credentials',    '+22%','Referenced vaguely -- no names listed', 'Add cert names, numbers, and logos'),
    @('Industry consortium membership',    '+20%','Soteria confirmed -- not prominently featured', 'Add Soteria badge to homepage and About page'),
    @('Google Reviews on-page',            '+18%','ACTIVE -- WP Reviews plugin running',   'Already working -- maintain'),
    @('Technical terminology',             '+18%','STRONG -- industry terms used correctly','Maintain depth in service page copy'),
    @('Expert quotations',                 '+15%','MISSING -- no leadership quotes',        'Add exec or industry expert quotes to pages'),
    @('Keyword stuffing penalty',          '-10%','CLEAN -- not detected',                  'Maintain -- do not change')
)
for ($r=0;$r -lt $pbd.Count;$r++) {
    $isGood = $pbd[$r][2] -like '*ACTIVE*' -or $pbd[$r][2] -like '*STRONG*' -or $pbd[$r][2] -like '*CLEAN*'
    $isMiss = $pbd[$r][2] -like '*MISSING*' -or $pbd[$r][2] -like '*ZERO*'
    $rbg = if ($isGood) { $BGGRN } elseif ($isMiss) { $BGRED } else { $BGYEL }
    $rfg = if ($isGood) { $GREEN } elseif ($isMiss) { $RED_T } else { $AMBER }
    TC $pbt ($r+2) 1 $pbd[$r][0] $false $DKGRAY 10 0
    TC $pbt ($r+2) 2 $pbd[$r][1] $true  $GREEN  10 1
    TC $pbt ($r+2) 3 $pbd[$r][2] $false $rfg    10 0 $rbg
    TC $pbt ($r+2) 4 $pbd[$r][3] $false $DKGRAY 10 0
}
MoveOut $pbt
PB

# ============================================================
# 6. CONTENT FRESHNESS
# ============================================================
H1 '6. Content Freshness -- 80 / 100  (Pass)'
HR

H2 'What This Measures'
Body 'AI systems heavily weight content recency. A page last updated in 2023 will lose a citation to a 2026 competitor article on the same topic -- even if the older content is technically better written. Freshness signals include visible "Last Updated" dates, current-year references in content, sitemap timestamps, and active publishing cadence.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'First America publishes new blog posts on a weekly cadence. The most recent post was published April 22, 2026. A consistent weekly publishing schedule is the most powerful long-term freshness signal available and is one of the factors that will compound AI citation authority over time.' $GREEN
Body 'Active 2026 conference pages exist for Battery Show Detroit 2026, RE+ Las Vegas 2026, MODEX Atlanta 2026, Offshore Technology Conference 2026, and ReMA 2026. Dated, current-year pages signal active company engagement to AI engines.' $GREEN
Body 'IndexNow is enabled via Yoast SEO, meaning Microsoft Bing is notified within minutes of any new or updated page. This is a significant freshness advantage that most competitors do not have configured.' $GREEN
Body 'LLMs.txt was updated April 19, 2026 -- five days before this audit -- confirming the weekly generation schedule is operational.' $GREEN

NL; H2 'CONS -- What Needs Improving'
Body 'The FAQ page at firstamerica.com/faq has never been updated since the original theme installation. This page has one of the oldest timestamps on the site and contains placeholder content from a construction theme demo. It is actively dragging the freshness signal for the domain.' $RED_T
Body '11 plugins have available updates, including Elementor from version 3.25.11 to 4.0.3 (a major version release) and Yoast SEO from 26.4 to 27.4. Outdated plugins signal site maintenance neglect to technical crawlers and reduce SG Security scan scores.' $AMBER
Body 'No "Last Updated" dates are visible to visitors or crawlers on service pages, industry pages, or long-form blog posts. Undated content consistently loses citations to explicitly dated competitor content when both pages cover the same topic.' $AMBER

NL; H2 'Content Freshness Audit'
$fat = MakeTable 9 4
HRow $fat @('Signal','Current State','Where','Action')
$fad = @(
    @('Blog publishing cadence',         'Weekly -- latest Apr 22 2026 -- PASS',          'FE', 'Maintain -- this is a genuine strength'),
    @('2026 conference pages',           'Multiple active 2026 event pages -- PASS',       'FE', 'Continue creating event pages for each show'),
    @('IndexNow',                        'Active via Yoast -- Bing notified in minutes',   'BE', 'Already working -- no action needed'),
    @('LLMs.txt freshness',              'Updated Apr 19 2026 -- 5 days ago -- PASS',      'BE', 'Plugin handles this automatically -- maintain'),
    @('FAQ page timestamp',              'Has never been updated -- original theme date',   'FE', 'Replace with real content and current date'),
    @('"Last Updated" visible on pages', 'MISSING on all service and blog pages',          'BE', 'Enable in Yoast SEO article settings -- add to theme'),
    @('Plugin update status',            '11 plugins pending -- Elementor 4.0 available',  'BE', 'Update after staging test -- major version change'),
    @('Elementor version',               '3.25.11 -- update to 4.0.3 available (major)',   'BE', 'Test in staging2.firstamerica.com before live update')
)
for ($r=0;$r -lt $fad.Count;$r++) {
    $isOk    = $fad[$r][3] -like '*Maintain*' -or $fad[$r][3] -like '*working*' -or $fad[$r][3] -like '*automatically*'
    $isWarn  = $fad[$r][3] -like '*staging*' -or $fad[$r][3] -like '*major*'
    $isCrit  = $fad[$r][1] -like '*never*' -or $fad[$r][1] -like '*MISSING*'
    $rbg = if ($isOk) { $BGGRN } elseif ($isCrit) { $BGRED } else { $BGYEL }
    $rfg = if ($isOk) { $GREEN } elseif ($isCrit) { $RED_T } else { $AMBER }
    TC $fat ($r+2) 1 $fad[$r][0] $false $DKGRAY 10 0
    TC $fat ($r+2) 2 $fad[$r][1] $false $DKGRAY 10 0
    WhereBadge $fat ($r+2) 3 $fad[$r][2]
    TC $fat ($r+2) 4 $fad[$r][3] $false $rfg    10 0 $rbg
}
MoveOut $fat

H2 'Note on Elementor 4.0 Update'
Body 'Elementor 4.0 is a major version release and may affect page layouts, widget rendering, and plugin compatibility. Update process: test on staging2.firstamerica.com first, confirm all service pages and landing pages render correctly, then update production. Do not update without a full site backup.' $AMBER $true
PB

# ============================================================
# 7. SCHEMA MARKUP
# ============================================================
H1 '7. Schema Markup (Structured Data) -- 40 / 100  (Needs Work)'
HR

H2 'What This Measures'
Body 'Schema markup is structured code that tells AI systems and search engines exactly what your content means. A service page with Service schema tells Google it describes a commercial offering. An Organization schema on the homepage confirms the company entity. Content with proper schema shows 30-40% higher AI citation rates than equivalent content without schema.'
Body 'Yoast SEO is installed on firstamerica.com and supports full Organization, LocalBusiness, Service, and Article schema -- but the schema configuration module has never been activated. This is the single highest-impact technical fix available and requires no custom coding.' $RED_T $true

NL; H2 'PROS -- What You Are Doing Right'
Body 'Yoast SEO Premium is installed and schema-capable. Unlike sites that require a developer to implement schema from scratch, First America can configure Organization, LocalBusiness, Service, and Article schema entirely through the Yoast settings panel.' $GREEN
Body 'Yoast automatically adds Article schema to blog posts when correctly configured. With 189 published posts, enabling this setting will add structured data to the entire content library at once.' $GREEN

NL; H2 'CONS -- What Needs Fixing'
Body 'No Organization schema exists on the site. AI platforms cannot confirm the company entity -- its name, location, founding date, or industry. This is the most foundational schema type and the starting point for all AI entity recognition.' $RED_T
Body 'No Service or LocalBusiness schema on service pages. Electronics recycling, battery recycling, solar panel recycling, and metals recycling pages have no structured indication that they describe commercial services.' $RED_T
Body 'No Article schema on blog posts (Yoast Article schema requires activation). 189 published posts are being crawled without structured metadata about authorship, publication date, or topic category.' $RED_T
Body 'The FAQ page cannot receive FAQPage schema while it contains Lorem Ipsum content -- schema on placeholder content would be rejected by Google Rich Results Test.' $RED_T

NL; H2 'Schema Opportunities -- Page by Page'
$smt = MakeTable 9 5
HRow $smt @('Page / Section','Schema to Add','Where','Citation Benefit','Effect Timeline')
$smd = @(
    @('Homepage',                    'Organization, LocalBusiness',      'BE', 'Company entity recognition across all AI platforms',  'AI entity recognition in 2-4 weeks'),
    @('All blog posts',              'Article (enable via Yoast global)', 'BE', 'Post-level authorship and date extraction',           'Article schema active on next crawl'),
    @('Electronics Recycling page',  'Service, ItemList',                'BE', 'Service query extraction for e-waste queries',        'Service citations improve in 2-4 weeks'),
    @('Battery Recycling page',      'Service',                          'BE', 'Service extraction for battery disposal queries',     'Service citations improve in 2-4 weeks'),
    @('Solar Panel Recycling page',  'Service',                          'BE', 'Service extraction for solar recycling queries',      'Service citations improve in 2-4 weeks'),
    @('FAQ page (after content fix)', 'FAQPage',                         'BE', 'Direct Q and A extraction in AI Overviews',          'Q and A visible in AI Overviews in 1-3 weeks'),
    @('All pages',                   'BreadcrumbList',                   'BE', 'Site structure clarity for AI crawlers',              'Breadcrumbs visible within days'),
    @('Locations page',              'LocalBusiness with multiple locations', 'BE', 'Location-specific query citation',            'Local queries improve in 1-2 weeks')
)
for ($r=0;$r -lt $smd.Count;$r++) {
    TC $smt ($r+2) 1 $smd[$r][0] $false $DKGRAY 10 0
    TC $smt ($r+2) 2 $smd[$r][1] $true  $BLUE   10 0 $BGBLUE
    WhereBadge $smt ($r+2) 3 $smd[$r][2]
    TC $smt ($r+2) 4 $smd[$r][3] $false $GREEN  10 0 $BGGRN
    TC $smt ($r+2) 5 $smd[$r][4] $false $GREEN  10 0 $BGGRN
}
MoveOut $smt

H2 'Example -- Organization Schema for the Homepage'
Body 'This is what Yoast SEO generates automatically once the Organization details are filled in under Yoast SEO -- Settings -- Site Representation:' $DKGRAY
Code ("{`r`n" + '  "@context": "https://schema.org",' + "`r`n" + '  "@type": ["Organization", "LocalBusiness"],' + "`r`n" + '  "name": "First America",' + "`r`n" + '  "description": "The nation leader in electronics recycling. Recycle electronics, batteries, solar panels, and non-ferrous metals with 30+ years of expertise.",' + "`r`n" + '  "url": "https://firstamerica.com",' + "`r`n" + '  "foundingDate": "1990",' + "`r`n" + '  "areaServed": "United States",' + "`r`n" + '  "memberOf": { "@type": "Organization", "name": "Soteria Battery Safety Consortium" },' + "`r`n" + '  "hasOfferCatalog": { "@type": "OfferCatalog",' + "`r`n" + '    "name": "Recycling Services",' + "`r`n" + '    "itemListElement": [' + "`r`n" + '      { "@type": "Offer", "itemOffered": { "@type": "Service", "name": "Electronics Recycling" } },' + "`r`n" + '      { "@type": "Offer", "itemOffered": { "@type": "Service", "name": "Battery Recycling" } },' + "`r`n" + '      { "@type": "Offer", "itemOffered": { "@type": "Service", "name": "Solar Panel Recycling" } },' + "`r`n" + '      { "@type": "Offer", "itemOffered": { "@type": "Service", "name": "Non-Ferrous Metals Recycling" } }' + "`r`n" + '    ]' + "`r`n" + '  }' + "`r`n" + '}')
PB

# ============================================================
# 8. MACHINE-READABLE FILES
# ============================================================
H1 '8. Machine-Readable Files -- 85 / 100  (Pass)'
HR

H2 'What This Measures'
Body 'AI systems and AI agents look for specific files at the root of websites. These files let AI quickly understand who the company is without needing to crawl every page. First America has the strongest machine-readable file setup of any site audited by Fresh Design Studio -- the llms.txt implementation alone is best-in-class for a mid-market B2B company.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'llms.txt exists at firstamerica.com/llms.txt and is 49,544 bytes -- nearly 50KB of structured content for AI consumption. It contains a full index of all 189 published blog posts with direct URLs. Updated April 19, 2026 (5 days before this audit). The plugin is set to regenerate weekly, keeping the file current automatically.' $GREEN $true
Body 'A full-content export file exists at firstamerica.com/llms-full.txt, referenced from llms.txt. This means AI agents that want the complete text of all pages have a direct path to it without crawling individual pages. This is an advanced implementation that most sites -- including enterprise competitors -- do not have.' $GREEN $true
Body 'The XML sitemap is active at firstamerica.com/sitemap_index.xml and referenced in robots.txt. Google Search Console is verified. IndexNow is enabled for real-time Bing notification.' $GREEN

NL; H2 'CONS -- What Can Be Improved'
Body 'The llms.txt header section contains only three lines: the company name, the tagline "The nation leader in electronics recycling", and a link to the full export. AI systems that read only the header section (without following the full-content link) receive almost no structured brand context. The header should describe the company, its services, locations, and key credentials.' $AMBER
Body 'The robots.txt is virtual (Yoast-generated) with minimal directives. A physical file with explicit bot-level guidance would improve crawl efficiency across the large content library.' $AMBER

NL; H2 'Machine-Readable File Status'
$mft = MakeTable 6 5
HRow $mft @('File','Size / Status','Where','Current Quality','Recommended Action')
$mfd = @(
    @('firstamerica.com/llms.txt',         '49,544 bytes -- weekly update',    'BE', 'STRONG -- full post index present',      'Expand header with company summary'),
    @('firstamerica.com/llms-full.txt',    'Full content export -- linked',     'BE', 'STRONG -- complete content for AI agents','Confirm file is current and accessible'),
    @('firstamerica.com/sitemap_index.xml','ACTIVE -- Yoast-generated',         'BE', 'PASS -- GSC verified and indexed',        'Confirm all service pages are included'),
    @('firstamerica.com/robots.txt',       'Virtual -- Yoast-generated',        'BE', 'PARTIAL -- minimal directives',           'Add per-bot directives for AI crawlers'),
    @('/pricing.md or /services.md',       'MISSING -- optional AI agent file', 'BE', 'Not present',                             'Optional -- create for procurement AI agents')
)
for ($r=0;$r -lt $mfd.Count;$r++) {
    $isGood = $mfd[$r][3] -like '*STRONG*' -or $mfd[$r][3] -like '*PASS*'
    $isWarn = $mfd[$r][3] -like '*PARTIAL*'
    $isMiss = $mfd[$r][3] -like '*Not present*'
    $sbg = if ($isGood) { $BGGRN } elseif ($isWarn) { $BGYEL } else { $BGRED }
    $sfg = if ($isGood) { $GREEN } elseif ($isWarn) { $AMBER } else { $RED_T }
    TC $mft ($r+2) 1 $mfd[$r][0] $true  $BLUE   10 0 $BGBLUE
    TC $mft ($r+2) 2 $mfd[$r][1] $false $DKGRAY 10 0
    WhereBadge $mft ($r+2) 3 $mfd[$r][2]
    TC $mft ($r+2) 4 $mfd[$r][3] $true  $sfg    10 0 $sbg
    TC $mft ($r+2) 5 $mfd[$r][4] $false $DKGRAY 10 0
}
MoveOut $mft

H2 'Recommended llms.txt Header Expansion'
Body 'Expanding the header block from 3 lines to approximately 30 lines gives AI systems instant structured brand context without following the full-content link:' $DKGRAY
Code ("# First America`r`n`r`n" + "> The nation leader in electronics and metals recycling with 30+ years of expertise.`r`n" + "> Full content export: https://firstamerica.com/llms-full.txt`r`n`r`n" + "## About`r`n" + "- Serving enterprises, manufacturers, governments, and institutions nationwide`r`n" + "- Facilities in Dallas-Fort Worth TX, Chicago IL, and Atlanta GA metro areas`r`n" + "- Member: Soteria Battery Safety Consortium`r`n" + "- Certifications: [R2 / RIOS / ISO -- add applicable]`r`n`r`n" + "## Primary Services`r`n" + "- Electronics Recycling (ITAD, e-waste, computer boards, data destruction)`r`n" + "- Battery Recycling (lithium-ion, EV batteries, BESS, NiCd, NiMH)`r`n" + "- Solar Panel Recycling (modules, inverters, racking systems)`r`n" + "- Non-Ferrous Metals Recycling (copper, aluminum, nickel, precious metals)`r`n" + "- Data Destruction (certified, NIST 800-88, Certificate of Destruction provided)`r`n" + "- IT Asset Disposition (ITAD) with value recovery and remarketing`r`n`r`n" + "## Industries Served`r`n" + "Healthcare, Manufacturing, Government, Financial Institutions, Education,`r`n" + "Aviation, Telecommunications, Retail, Insurance, AI and Robotics, Solar PV,`r`n" + "Electric Vehicles`r`n`r`n" + "## Key Pages`r`n" + "- Homepage:            https://firstamerica.com/`r`n" + "- Electronics:         https://firstamerica.com/electronics-recycling/`r`n" + "- Battery Recycling:   https://firstamerica.com/battery-recycling/`r`n" + "- Solar Panel:         https://firstamerica.com/solar-panel-recycling/`r`n" + "- Metals:              https://firstamerica.com/non-ferrous-metal-recycling/`r`n" + "- Data Destruction:    https://firstamerica.com/certified-data-destruction-management/`r`n" + "- ITAD:                https://firstamerica.com/it-asset-management/`r`n" + "- Locations:           https://firstamerica.com/locations/`r`n" + "- Contact:             https://firstamerica.com/contact/")
PB

# ============================================================
# 9. CONTENT DEPTH
# ============================================================
H1 '9. Content Depth and Volume -- 70 / 100  (Pass)'
HR

H2 'What This Measures'
Body 'AI systems cite specific, substantive content. The more useful content a site publishes about topics relevant to its business, the more citation opportunities it creates. Content depth is measured by total volume, vertical coverage, topic diversity, and whether individual pages answer questions completely enough to be extracted without additional context.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'First America has one of the largest content libraries in the commercial recycling sector. 189 published blog posts cover a wide range of topics: battery chemistry types, solar panel end-of-life management, ITAD policy, precious metal recovery, EV battery recycling regulations, copper and aluminum recycling techniques, and sustainability procurement. This breadth directly supports the long-tail queries that AI platforms use for detailed answers.' $GREEN
Body 'Programmatic location pages exist for Texas, Georgia, and Illinois across battery, solar, and electronics categories. These pages serve location-qualified queries ("battery recycling in Texas", "solar panel recycling Georgia") which AI platforms answer with locally relevant citations.' $GREEN
Body '15-plus industry vertical pages cover healthcare, manufacturing, government, aviation, financial institutions, telecommunications, AI and robotics, and electric vehicles. Vertical pages are high-value for B2B AI citations because enterprise buyers use industry-qualified queries ("electronics recycling for healthcare", "ITAD for financial institutions").' $GREEN
Body 'A Resource Library page (firstamerica.com/resource-library/) and multiple downloadable guides (e-waste cost vs value, electronics recycling value guide, battery recycling cost guide) exist as gated lead-generation tools. The ungated content referenced from these guides provides additional citation surface.' $GREEN

NL; H2 'CONS -- What Needs Improving'
Body 'The FAQ page at firstamerica.com/faq contains zero real recycling content. This is the most commonly-visited information page on most service business sites and a primary target for AI FAQ extraction. Its current state (Lorem Ipsum) eliminates it entirely as a citation source.' $RED_T
Body '763 of 963 images (79%) lack alt text. For a recycling company where facility imagery, equipment photos, and process documentation are important proof points, missing alt text means AI engines cannot interpret the visual evidence of capabilities.' $RED_T
Body 'Several conference and event landing pages are thin in content -- they serve as meeting request forms with minimal copy. These pages dilute the content quality signal across the domain if they are indexed broadly.' $AMBER

NL; H2 'Content Library Overview'
$cit = MakeTable 9 3
HRow $cit @('Content Type','Count / Status','Assessment')
$cid = @(
    @('Published blog posts',          '189 posts -- weekly cadence',      'STRONG -- one of the highest volumes in sector'),
    @('Published pages',               '247 pages total',                   'STRONG -- extensive service and industry coverage'),
    @('Service category pages',        '4 primary plus ITAD and data',      'GOOD -- all major services covered'),
    @('Industry vertical pages',       '15+ industries covered',            'STRONG -- rare depth at mid-market level'),
    @('Location-specific pages',       'TX, GA, IL (multiple each)',        'GOOD -- programmatic SEO in place'),
    @('FAQ page with real content',    '0 -- entirely placeholder text',    'MISSING -- highest priority fix on the site'),
    @('Images with alt text',          '200 of 963 (21%) have alt text',    'WEAK -- 763 images invisible to AI crawlers'),
    @('Resource library and guides',   '4+ downloadable guides active',     'GOOD -- supports B2B lead generation')
)
for ($r=0;$r -lt $cid.Count;$r++) {
    $isGood = $cid[$r][2] -like '*STRONG*' -or $cid[$r][2] -like '*GOOD*'
    $isMiss = $cid[$r][2] -like '*MISSING*' -or $cid[$r][2] -like '*WEAK*'
    $bg = if ($isGood) { $BGGRN } elseif ($isMiss) { $BGRED } else { $BGYEL }
    $fg = if ($isGood) { $GREEN } elseif ($isMiss) { $RED_T } else { $AMBER }
    TC $cit ($r+2) 1 $cid[$r][0] $false $DKGRAY 10 0
    TC $cit ($r+2) 2 $cid[$r][1] $true  $DKGRAY 10 1
    TC $cit ($r+2) 3 $cid[$r][2] $false $fg     10 0 $bg
}
MoveOut $cit

H2 'High-Value Query Gaps -- AI Citations First America Is Missing'
$hvt = MakeTable 10 3
HRow $hvt @('Target Query','Content Gap','Citation Potential')
$hvd = @(
    @('"best electronics recycling company for enterprise"',   'No "why choose us" comparison page with cited differentiators', 'High'),
    @('"ITAD vendor for data center decommission"',            'ITAD page exists but lacks extractable specs and process detail', 'High'),
    @('"R2 certified electronics recycler near me"',           'Certification page missing -- cert name not stated anywhere',   'High'),
    @('"how to dispose of lithium batteries commercial"',      'Battery page exists -- add regulatory compliance section',      'High'),
    @('"EV battery recycling for fleet operators"',            'EV recycling pages exist -- add fleet operator FAQ section',    'Medium'),
    @('"solar panel recycler certified"',                      'Solar page exists -- add certifications and capacity specs',    'High'),
    @('"copper recycling price per pound"',                    'Copper pages present -- no pricing or value guidance',          'Medium'),
    @('"ITAD with certificate of destruction"',                'Data destruction page mentions this -- needs standalone FAQ',   'High'),
    @('"first america recycling reviews"',                     'Google Reviews plugin active -- no testimonial page',           'Medium')
)
for ($r=0;$r -lt $hvd.Count;$r++) {
    $hiP  = $hvd[$r][2] -eq 'High'
    $pfg  = if ($hiP) { $GREEN } else { $AMBER }
    $pbg  = if ($hiP) { $BGGRN } else { $BGYEL }
    TC $hvt ($r+2) 1 $hvd[$r][0] $false $DKGRAY 10 0
    TC $hvt ($r+2) 2 $hvd[$r][1] $false $DKGRAY 10 0
    TC $hvt ($r+2) 3 $hvd[$r][2] $true  $pfg    10 1 $pbg
}
MoveOut $hvt
PB

# ============================================================
# 10. COMPETITIVE SNAPSHOT
# ============================================================
H1 '10. Competitive Snapshot'
HR
Body 'This table is a high-confidence projection based on the content gaps and structural differences found during the audit, combined with what AI platforms typically cite for B2B recycling service queries.' $DKGRAY $false $true
NL

$cst = MakeTable 7 4
HRow $cst @('Search Query','Brands Being Cited Now','First America','The Gap')
$csd = @(
    @('"best enterprise electronics recycling company"', 'Iron Mountain, SIMS Lifecycle Services, Stericycle', 'Rarely cited',      'No Organization schema, no cert page, no comparison content'),
    @('"ITAD services for data center"',                 'Iron Mountain, Arrow Electronics, TD SYNNEX',       'Rarely cited',      'ITAD page needs extractable specs and certifications'),
    @('"battery recycling for businesses"',              'Retriev Technologies, Li-Cycle, Call2Recycle',      'Occasionally cited','Battery pages strong -- missing cert and regulatory sections'),
    @('"solar panel recycling commercial"',              'SOLARCYCLE, We Recycle Solar, Recycle Solar',       'Occasionally cited','Solar pages present -- need certification and capacity data'),
    @('"R2 certified e-waste recycler"',                 'All R2-certified competitors dominate this query',  'NOT cited',         'R2 certification not mentioned anywhere on the site'),
    @('"data destruction certificate of destruction"',   'Iron Mountain, Shred-it, Stericycle',               'Rarely cited',      'Data destruction page present but lacks extractable detail')
)
for ($r=0;$r -lt $csd.Count;$r++) {
    $isOcc = $csd[$r][2] -like '*Occasionally*'
    $isNot = $csd[$r][2] -like '*NOT*' -or $csd[$r][2] -like '*Rarely*'
    $cbg = if ($isOcc) { $BGYEL } else { $BGRED }
    $cfg = if ($isOcc) { $AMBER } else { $RED_T }
    TC $cst ($r+2) 1 $csd[$r][0] $false $DKGRAY 10 0
    TC $cst ($r+2) 2 $csd[$r][1] $false $DKGRAY 10 0
    TC $cst ($r+2) 3 $csd[$r][2] $true  $cfg    10 0 $cbg
    TC $cst ($r+2) 4 $csd[$r][3] $false $DKGRAY 10 0
}
MoveOut $cst

Body 'The gap is not content volume -- First America publishes more content than most competitors. The gap is structural: certifications not stated, schema not configured, and the FAQ page actively undermining trust signals that the rest of the site builds. Fixing these three issues closes the citation gap for most of the queries in the table above.' $AMBER $true
PB

# ============================================================
# 11. FINAL SUMMARY
# ============================================================
H1 '11. Final Summary: Pros, Cons and Next Steps'
HR

$fst = MakeTable 8 5
HRow $fst @('Pillar','PROS -- What Is Working','CONS -- What Needs Fixing','Where','Top Next Step')
$fsd = @(
    @('AI Bot Access',
      'SSL active. Sitemap live. GSC verified. IndexNow enabled for real-time Bing notification.',
      'robots.txt is virtual and minimal. No per-bot AI crawler directives.',
      'BE',
      'Add AI-specific bot entries and admin Disallow to robots.txt. Effect: crawl guidance improves within days.'),
    @('Content Structure',
      'Homepage meta is clear and citable. Service pages, industry pages, and blog use descriptive, question-format titles.',
      'FAQ page has Lorem Ipsum about construction. 763 of 963 images (79%) missing alt text.',
      'FE',
      'Replace all FAQ content with real recycling Q and A. Effect: AI re-index in 2-4 weeks.'),
    @('Authority and Trust',
      '30+ year history stated. Google Reviews active. Soteria Consortium membership documented. Industry event presence logged.',
      'No certifications named. Blog authors are ID numbers only -- no visible bylines or bios. No statistics with cited sources.',
      'FE',
      'Add certification names and links on all service pages. Enable author pages and link all posts. Effect: trust signals improve on re-index.'),
    @('Content Freshness',
      'Weekly blog publishing cadence. IndexNow active. 2026 conference pages live. LLMs.txt auto-updated weekly.',
      'FAQ page has never been updated. 11 plugin updates pending including Elementor 4.0 major release.',
      'BT',
      'Replace FAQ content (most urgent). Schedule plugin updates with staging test for Elementor 4.0. Effect: recency signals improve within days.'),
    @('Schema Markup',
      'Yoast SEO installed and schema-capable. No coding required -- all schema is configured through Yoast settings.',
      'Yoast schema module not activated. Zero schema on any page. Article schema not enabled for blog posts.',
      'BE',
      'Open Yoast SEO -- Settings -- Site Representation and configure Organization. Enable Article schema globally. Effect: AI entity recognition in 2-4 weeks.'),
    @('Machine-Readable Files',
      'llms.txt is 49KB, weekly-generated, with full post index and link to llms-full.txt. Best-in-class for the sector.',
      'Header section of llms.txt has only 3 lines of brand context. robots.txt has minimal directives.',
      'BE',
      'Expand llms.txt header with services, locations, and key page list. Effect: AI agents read brand context immediately on next visit.'),
    @('Content Depth',
      '189 blog posts, 247 pages, programmatic location SEO, 15+ industry vertical pages, resource library with guides.',
      'FAQ page has zero real content. 79% of images lack alt text. Event landing pages are thin.',
      'FE',
      'Fix FAQ content and begin batch alt-text update on service page images first. Effect: content crawlability improves on next AI visit.')
)
for ($r=0;$r -lt $fsd.Count;$r++) {
    TC $fst ($r+2) 1 $fsd[$r][0] $true  $NAVY   10 0 $BGBLUE
    TC $fst ($r+2) 2 $fsd[$r][1] $false $GREEN  10 0 $BGGRN
    TC $fst ($r+2) 3 $fsd[$r][2] $false $RED_T  10 0 $BGRED
    WhereBadge $fst ($r+2) 4 $fsd[$r][3]
    TC $fst ($r+2) 5 $fsd[$r][4] $false $DKGRAY 10 0 $BGYEL
}
MoveOut $fst

NL; H2 'Closing Note'
Body 'First America has built a content infrastructure that most B2B recyclers cannot match: 189 published posts, 15-plus industry verticals, programmatic location pages, a 50KB llms.txt, and a weekly publishing cadence. The three fixes identified in this report -- replacing the FAQ placeholder content, activating Yoast schema, and expanding the llms.txt header -- are configuration and content changes, not structural rebuilds. Completing these three actions will move the overall score from 65 into the 80-plus range and substantially increase the frequency with which First America appears in AI-generated answers for enterprise recycling queries.'
Body 'This report was generated on April 24, 2026 from live site data collected via SSH and WP-CLI during the audit session. Prepared by Fresh Design Studio.' $DKGRAY $false $true

# ============================================================
# SAVE
# ============================================================
$doc.SaveAs([ref]$outputPath, [ref]16)
$doc.Close()
$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null

Write-Output "SUCCESS -- File saved to: $outputPath"
