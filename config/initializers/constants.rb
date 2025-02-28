ROLE = ["SuperAdmin", "Accountant", "Promoter", "Employee"].freeze
SHARE_PRICE = 10


APP_BANK_LIST = [
  "Allahabad Bank","Allahabad U.P Gramin Bank","Andhra Bank","AU Small Finance Bank","Axis Bank","Bandhan Bank","Bank of Bahrain and Kuwait","Bank of Baroda","Bank of Baroda - Corporate Banking","Bank of Baroda - Retail Banking","Bank of India","Bank of Maharashtra","Bharatiya Mahila Bank Limited","Catholic Syrian Bank","Canara Bank","Central Bank of India","Corporation Bank","Dena Bank","District Cooperative Bank","Federal Bank","Fincare Small Finance Bank","HDFC Bank","Himachal Pradesh Gramin Bank","ICICI Bank","Idbi Bank Ltd","Indian Bank","Indian Overseas Bank","Indusind Bank Ltd","Jammu and Kashmir Bank","JK Bank Ltd.","Kangra Central Co-Op Bank Limited","Kotak Bank","Oriental Bank of Commerce","Paytm Payments Bank","Post Office Saving Bank","Punjab Gramin Bank","Punjab and Sind Bank","Punjab National Bank","Punjab National Bank - Retail Banking","Punjab National Bank - Corporate Banking","South Indian Bank","State Bank of India","State Bank of Patiala","Syndicate Bank","The Citizen Co-Operative Bank Ltd.","The Himachal Pradesh State Cooperative Bank Ltd","UCO Bank","Union Bank of India","United Bank of India","Vijaya Bank","Yes Bank Ltd"
].freeze

PRODUCT_UNITS= [
  "Kg",
  "ltr",
  "mtr",
  "pcs",
  "unit",
  "nos",
  "roll",
  "set",
  "kit"
].freeze
NOMINEE_RELATION =
  ["Father","Mother","Son","Daughter","Spouse (Husband/ Wife)","Husband","Wife","Brother","Sister","Daughter in Law","Brother in Law","Grand Daughter","Grand Son","Nephew","Niece","Other"].freeze

ALLOWANCE_DEDUCTION =[

  {id:1,  name: "Basic salary", type: "allowance"},
  {id:2,  name: "Home Rent allowance", type: "allowance"},
  {id:3,  name: "Medicine", type: "allowance"},
  {id:4,  name: "Project allowance", type: "allowance"},
  {id:5,  name: "Transport allowance", type: "allowance"},
  {id:6,  name: "Overtime allowance", type: "allowance"},
  {id:7,  name: "Entertainment", type: "allowance"},
  {id:8,  name: "PF", type: "deduction"},
  {id:9,  name: "Tax", type: "deduction"},
  {id:10, name: "Employer PF Share", type: "allowance"},
  # {id:11, name: "Advance Payment", type: "deduction"},
  # {id:12, name: "Absence Deduction", type: "deduction"},
]
STATE_GST = [
  { state_name: "Jammu and Kashmir", gst_code: "01" },
  { state_name: "Himachal Pradesh", gst_code: "02" },
  { state_name: "Punjab", gst_code: "03" },
  { state_name: "Chandigarh", gst_code: "04" },
  { state_name: "Uttarakhand", gst_code: "05" },
  { state_name: "Haryana", gst_code: "06" },
  { state_name: "Delhi", gst_code: "07" },
  { state_name: "Rajasthan", gst_code: "08" },
  { state_name: "Uttar Pradesh", gst_code: "09" },
  { state_name: "Bihar", gst_code: "10" },
  { state_name: "Sikkim", gst_code: "11" },
  { state_name: "Arunachal Pradesh", gst_code: "12" },
  { state_name: "Nagaland", gst_code: "13" },
  { state_name: "Manipur", gst_code: "14" },
  { state_name: "Mizoram", gst_code: "15" },
  { state_name: "Tripura", gst_code: "16" },
  { state_name: "Meghalaya", gst_code: "17" },
  { state_name: "Assam", gst_code: "18" },
  { state_name: "West Bengal", gst_code: "19" },
  { state_name: "Jharkhand", gst_code: "20" },
  { state_name: "Odisha", gst_code: "21" },
  { state_name: "Chhattisgarh", gst_code: "22" },
  { state_name: "Madhya Pradesh", gst_code: "23" },
  { state_name: "Gujarat", gst_code: "24" },
  { state_name: "Daman and Diu", gst_code: "25" },
  { state_name: "Dadra and Nagar Haveli", gst_code: "26" },
  { state_name: "Maharashtra", gst_code: "27" },
  { state_name: "Andhra Pradesh (Before reorganization)", gst_code: "28" },
  { state_name: "Karnataka", gst_code: "29" },
  { state_name: "Goa", gst_code: "30" },
  { state_name: "Lakshadweep", gst_code: "31" },
  { state_name: "Kerala", gst_code: "32" },
  { state_name: "Tamil Nadu", gst_code: "33" },
  { state_name: "Puducherry", gst_code: "34" },
  { state_name: "Andaman and Nicobar Islands", gst_code: "35" },
  { state_name: "Telangana", gst_code: "36" },
  { state_name: "Andhra Pradesh (New)", gst_code: "37" },
  { state_name: "Ladakh", gst_code: "38" },
  { state_name: "Other Territory", gst_code: "97" }
]

# name for referece types
# 1 = promoters
