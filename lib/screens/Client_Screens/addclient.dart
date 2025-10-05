import 'package:erptransportexpress/Common%20Widgets/Common_CheckBox.dart';
import 'package:erptransportexpress/Common%20Widgets/Common_DropdownWidget.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/addresslist.dart';
import 'package:erptransportexpress/utils/Colors.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_form_filed.dart';

// ... (Existing global lists and class imports remain the same) ...
DateTime? contractStartDate;
DateTime? contractEndDate=DateTime(2025,3,30);
final List selectedModes=[
  "To be Billed",
  "To pay",
  "Bill On Date",
  "Paid",
];






final List<Map<String, String>> nashikWarehouses = [
  // ... (Your warehouse list) ...
  {
    "name": "Anusaya Warehousing Complex",
    "address": "Gut No. 187, Village Jaulke, Taluka Dindori, Nashik",
  },
  {
    "name": "Bhaskar Murlidhar Bhamare Sompur VKSS",
    "address": "Sompur-Baglan, Nashik",
  },
  {"name": "Bhatgaon VKSS", "address": "Bhatgaon-Chandwad, Nashik"},
  {
    "name": "Chairman Late Ashokrao Bankar Nagari Sahakari Patsanstha Ltd",
    "address": "AP Pimpalgaon B, Taluka Niphad, Nashik",
  },
  {
    "name": "Dwarkadhish Sakhar Karkhana Ltd.",
    "address": "Factory Site At Shevarae, Taluka Baglan, Nashik",
  },
  {
    "name": "Gangurde Warehouse",
    "address": "GNo-108, Mz: Jaulke, Taluka Dindori, Nashik",
  },
  {"name": "Gorakh Narsingrao Balkawade (Bhagur VKS Socy)", "address": "Nasik"},
  {"name": "M/S Agarwal Warehousing", "address": "Vilcholi, Nashik"},
  {
    "name": "M/S Anand Warehousing",
    "address": "S No. 156, Mumbai-Agra Highway, At Jaulke (Ozar), Nashik",
  },
  {"name": "M/S Baphana Warehousing Pvt. Ltd", "address": "Jaulke, Nashik"},
  {
    "name": "M/S Baphana Warehousing Pvt. Ltd., Tilakwadi",
    "address": "Tilakwadi, Nashik",
  },
  {
    "name": "M/S Dwarakadhish Sakhar Karkhana Ltd.",
    "address": "Sheware, Nashik",
  },
  {
    "name": "M/S Falbag Va Bhajipal K V Sah. Sanstha",
    "address": "Andursul, Nashik",
  },
  {
    "name": "M/S Jondhale’s Warehousing Complex",
    "address": "Gat No.141/1 & 141/2, Jaulke, Taluka Dindori, Nashik",
  },
  {"name": "M/S Palkhed VKS", "address": "Niphad, Nashik"},
  {
    "name": "M/S Pournima Warehousie",
    "address": "GNo-570, Khambale, Taluka Igatpuri, Nashik",
  },
  {"name": "M/S S. M Ratnaparkhi", "address": "Girnanagar, Nashik"},
  {
    "name": "M/S Siddhivinayak Warehousing & Agroprocessing",
    "address": "GNo-30, Mohadi, Taluka Dindori, Nashik",
  },
  {
    "name": "Maharashtra State Warehousing Corporation (MSWC)",
    "address": "Sinnar, Nashik",
  },
  {
    "name": "Maharashtra State Warehousing Corporation (2 units)",
    "address": "Plot No. E-9, MIDC Sinnar, Nashik",
  },
  {
    "name": "Mr Nilesh S Baphana",
    "address": "Po: Pimpalgaon-Baswant, Tal: Niphad, Nashik",
  },
  {
    "name": "Mr Omkar Ramgopal Dhut",
    "address": "A P Wavi, Tal: Sinnar, Nashik",
  },
  {
    "name": "Mr Sunil Kantilal Baphana",
    "address": "A/P: Pimpalgaon-Baswant, Tal: Niphad, Nashik",
  },
  {
    "name": "Central Warehouse, Nashik Road",
    "address": "Deolali Gaon, Opp Urdu School, Nashik Road, Nashik",
  },
  {"name": "Ambad (Nashik) Warehouse", "address": "H-105 MIDC, Ambad, Nashik"},
  {
    "name": "Manmad (APMC Market Yard)",
    "address": "Chanwad Road, Manmad, Nashik",
  },
  {"name": "Malegaon (Market Yard)", "address": "Malegaon, Nashik"},
  {"name": "Nampur (APMC Market Yard)", "address": "Nampur, Nashik"},
  {"name": "Kalwan, Market Yard", "address": "Kalwan, Nashik District"},
  {"name": "Lasalgaon, Market Yard", "address": "Lasalgaon, Nashik District"},
  {"name": "Satana, Malegaon Road", "address": "Satana, Nashik District"},
  {
    "name": "Sinnar Warehouse",
    "address": "Plot No. E-9, MIDC Sinnar Area, Taluka Sinnar, Nashik",
  },
  {
    "name": "Export Facility Mohadi",
    "address": "Submarket Yard, Mohadi, Taluka Dindori, Nashik",
  },
  {
    "name": "Export Facility Kalwan",
    "address": "APMC, Bhendi Taluka, Kalwan, Nashik",
  },
  {
    "name": "Export Facility Chandwad",
    "address": "APMC, Chandwad, Taluka Chandwad, Nashik",
  },
  {
    "name": "Cold Storage Jaulke",
    "address": "Jaulke Village, Taluka Dindori, Nashik",
  },
  {"name": "Baphana Warehousing Pvt. Ltd", "address": "Jaulke, Nashik"},
  {
    "name": "Central Warehouse Nashik Road",
    "address": "Deolali Gaon, Opp Urdu School, Nashik Road, Nashik",
  },
];
String? selectedDeliveryOptions;


class AddClient extends StatefulWidget {
  final bool isClientEditable;
  const AddClient({super.key, this.isClientEditable = false});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  String? selectedType;
  // **********************************************
  // 1. New state variable for selected payment terms
  // **********************************************
  List<String> selectedPaymentTerms = [];


  final clientNameController = TextEditingController();
  final addressController = TextEditingController();
  final logisticsHeadName = TextEditingController();
  final logisticsHeadMobile = TextEditingController();
  final logisticsHeadEmail = TextEditingController();
  final rateTonController = TextEditingController();
  final rateTripController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  final rateRouteController = TextEditingController();
  final emailController = TextEditingController();
  final gstNumberController = TextEditingController();
  final businessTypeController = TextEditingController();
  final contractStartController = TextEditingController();
  final contractEndController = TextEditingController();
  final billingEmailController = TextEditingController();
  final billingAddressController = TextEditingController();

  final TextEditingController fifty_to_hundred = TextEditingController();
  final TextEditingController hundred_to_fivehundred = TextEditingController();
  final TextEditingController five_hundred_to_one_thousand =
  TextEditingController();
  final TextEditingController one_thousand_to_one_thousand_fivehundred =
  TextEditingController();
  final TextEditingController one_thousand_five_hundred_to_three_thousand =
  TextEditingController();
  final TextEditingController three_thousand_to_five_thousand =
  TextEditingController();

  final TextEditingController districtController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  final TextEditingController warehouselandmark = TextEditingController();

  bool directCharge = false;
  bool isFob = false;
  bool isODA = false;
  bool isHandlingCharge = false;
  bool isFuelSurCharge = false;

  TextEditingController directChargeControlelr = TextEditingController(
    text: "0",
  );
  TextEditingController fobController = TextEditingController(text: "0");
  TextEditingController odaController = TextEditingController(text: "0");
  TextEditingController handlingChargeController = TextEditingController(
    text: "0",
  );
  TextEditingController fuelSurChargeController = TextEditingController(
    text: "0",
  );

  final TextEditingController deliverytypecontroller = TextEditingController();


  List<Map<String, String>> filteredWarehouses = [];
  List<Map<String, String>> selectedWarehouses = [];
  OverlayEntry? _overlayEntry;
  final districtControllerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    districtController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = districtController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredWarehouses = [];
        _hideOverlay();
      } else {
        filteredWarehouses = nashikWarehouses
            .where((wh) => wh['name']!.toLowerCase().contains(query))
            .take(10)
            .toList();
        if (filteredWarehouses.isNotEmpty)
          _showOverlay();
        else
          _hideOverlay();
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();
    final overlay = Overlay.of(context);
    RenderBox box =
    districtControllerKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + box.size.height,
        width: box.size.width,
        child: Material(
          elevation: 4,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            color: Colors.white,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredWarehouses.length,
              itemBuilder: (context, index) {
                final warehouse = filteredWarehouses[index];
                return ListTile(
                  title: Text(warehouse['name']!),
                  subtitle: Text(warehouse['address']!),
                  onTap: () {
                    selectWarehouse(warehouse);
                    _hideOverlay();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void selectWarehouse(Map<String, String> warehouse) {
    if (!selectedWarehouses.any((wh) => wh['name'] == warehouse['name'])) {
      setState(() {
        selectedWarehouses.add(warehouse);
        districtController.clear();
      });
    }
  }

  void removeWarehouse(int index) {
    setState(() {
      selectedWarehouses.removeAt(index);
    });
  }

  Widget _buildSelectedWarehouseCard(Map<String, String> wh, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        color: Colors.grey[200],
        elevation: 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      wh['name']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => removeWarehouse(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                wh['address']!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }



  void selectPaymentTerm(String? term) {
    if (term != null && !selectedPaymentTerms.contains(term)) {
      setState(() {
        selectedPaymentTerms.add(term);
        // We don't clear a text controller here, but we can set the dropdown value to null
        // so the user can select another option.
        // Note: The CommonDropDownWidget needs to support setting its internal value to null/default
        // to show the hint again, or we rely on the user to re-select.
      });
    }
  }

  void removePaymentTerm(int index) {
    setState(() {
      selectedPaymentTerms.removeAt(index);
    });
  }

  Widget _buildSelectedPaymentTermCard(String term, int index) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.only(right: 15, bottom: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              term,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black
                ,
                fontWeight: FontWeight.w500,

              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => removePaymentTerm(index),
              child: Icon(
                Icons.delete,
                color: Colors.red,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    clientNameController.dispose();
    addressController.dispose();
    logisticsHeadName.dispose();
    logisticsHeadMobile.dispose();
    logisticsHeadEmail.dispose();
    rateTonController.dispose();
    rateTripController.dispose();
    rateRouteController.dispose();
    emailController.dispose();
    gstNumberController.dispose();
    businessTypeController.dispose();
    contractStartController.dispose();
    contractEndController.dispose();
    billingEmailController.dispose();
    billingAddressController.dispose();
    districtController.dispose();
    townController.dispose();
    pincodeController.dispose();
    landmark.dispose();
    warehouselandmark.dispose();
    fifty_to_hundred.dispose();
    hundred_to_fivehundred.dispose();
    five_hundred_to_one_thousand.dispose();
    one_thousand_to_one_thousand_fivehundred.dispose();
    one_thousand_five_hundred_to_three_thousand.dispose();
    three_thousand_to_five_thousand.dispose();
    directChargeControlelr.dispose();
    fobController.dispose();
    odaController.dispose();
    handlingChargeController.dispose();
    fuelSurChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: common_Colors.primaryColor,
        title: Text(
          widget.isClientEditable ? "View Client" : "Edit Client",
          style: TextStyle(color: common_Colors.textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Client Name and Address Row
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: false,
                        prefixIcon: const Icon(
                          Icons.person,
                        ),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: 'Client/Company Name',
                        hint: 'Enter Client/Company Name',
                        controller: clientNameController,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: false,
                        prefixIcon: const Icon(
                          Icons.location_on,
                        ),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: 'Address',
                        hint: 'Enter Address',
                        controller: addressController,
                      ),
                    ),
                  ],
                ),
                // Logistics Head and Service Type Row
                Row(
                  children: [
                    Expanded(
                      child: CommonDropDownWidget<String>(
                        hintText: "Service Type",
                        items: const [
                          DropdownMenuItem(
                            value: "Courier",
                            child: Expanded(
                                child: Text(
                                    "  Courier",style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),
                                )),
                          ),
                          DropdownMenuItem(
                            value: "PTL",
                            child: Text(" PTL",style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),),
                          ),
                          DropdownMenuItem(
                            value: "FTL",
                            child: Text(" FTL",style: TextStyle(
                              overflow: TextOverflow.ellipsis
                            ),),
                          ),
                        ],
                        value: selectedType,
                        onChanged: (val) {
                          setState(() {
                            selectedType = val;
                            typeController.text = val ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        keyboardType:TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.call,
                        ),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: ' Logistics Head Contact Number',
                        hint: 'Enter Contact Number',
                        controller: logisticsHeadMobile,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: false,
                        prefixIcon: const Icon(
                          Icons.person_pin_circle_sharp,
                        ),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: ' Logistics Head Name',
                        hint: 'Enter Logistics Head Name',
                        controller: logisticsHeadName,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: false,
                        prefixIcon: const Icon(
                          Icons.alternate_email_outlined,
                        ),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: ' Logistics Head Email',
                        hint: 'Enter Logistics Head Email',
                        controller: logisticsHeadEmail,
                      ),
                    ),
                  ],
                ),

                // Rate Slabs Row
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                        ),
                        caplebal: '',
                        label: 'Rate 50-100',
                        hint: 'Rate 50-100',
                        controller: fifty_to_hundred,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                        ),
                        caplebal: '',
                        label: 'Rate 100-500',
                        hint: 'Rate 100-500',
                        controller: hundred_to_fivehundred,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                        ),
                        caplebal: '',
                        label: 'Rate 500-1000',
                        hint: 'Rate 500-1000',
                        controller: five_hundred_to_one_thousand,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                        ),
                        caplebal: '',
                        label: 'Rate 1000-1500',
                        hint: 'Rate 1000-1500',
                        controller: one_thousand_to_one_thousand_fivehundred,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                        ),
                        caplebal: '',
                        label: 'Rate 1500-3000',
                        hint: 'Rate 1500-3000',
                        controller: one_thousand_five_hundred_to_three_thousand,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                        ),
                        caplebal: '',
                        label: 'Rate 3000-5000',
                        hint: 'Rate 3000-5000',
                        controller: three_thousand_to_five_thousand,
                      ),
                    ),
                  ],
                ),

                // ********************* BUSINESS LOCATION (Warehouse Selection) ****************
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Business Location (Warehouse Selection)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // SearchBar
                      CustomFormField(
                        allowOnlyNumbers: false,
                        key: districtControllerKey,
                        prefixIcon: const Icon(
                          Icons.search,
                        ),
                        suffixIcon: const Icon(
                          Icons.add_circle_sharp,
                          color: Colors.green,
                        ),
                        caplebal: "",
                        label: "Search Location here",
                        hint: "Search",
                        controller: districtController,
                      ),
                      const SizedBox(height: 10),
                      // Only show selected warehouses if any exist
                      if (selectedWarehouses.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                            selectedWarehouses.asMap().entries.map((entry) {
                              int idx = entry.key;
                              Map<String, String> wh = entry.value;
                              return Container(
                                width: 400,
                                margin: const EdgeInsets.only(right: 10),
                                child: _buildSelectedWarehouseCard(wh, idx),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),

                // ********************* END BUSINESS LOCATION BLOCK ****************
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Additional Charges",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        caplebal: "",
                        label: "Free on Board(Charges)",
                        hint: "Enter Charges",
                        controller: fobController,
                      ),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        caplebal: "",
                        label: "Direct Charges",
                        hint: "Enter Charges",
                        controller: directChargeControlelr,
                      ),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        caplebal: "",
                        label: "Handling Charge",
                        hint: "Enter Charges",
                        controller: handlingChargeController,
                      ),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        caplebal: "",
                        label: "Fuel Surcharge",
                        hint: "Enter Charge",
                        controller: fuelSurChargeController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Contract Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Row(
                  children: [
                    CommonButton(
                      borderRadius: 50,
                      backgroundColor: Colors.deepPurple,
                      text: contractStartDate != null
                          ? "${contractStartDate!.day}/${contractStartDate!.month}/${contractStartDate!.year}"
                          : "Start Date",
                      onPressed: () async{
                        DateTime? date=await  showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000),
                          initialDate: contractStartDate,



                        );
                        if(date!=null){
                          setState(() {
                            contractStartDate=date;
                          });
                        }



                      },
                    ),
                    SizedBox(width: 20),
                    CommonButton(

                      borderRadius: 50,
                      backgroundColor: Colors.deepPurple,
                      text: contractEndDate != null
                          ? "${contractEndDate!.day}/${contractEndDate!.month}/${contractEndDate!.year}"
                          : "End Date",
                      onPressed: () async{
                        DateTime? date=await  showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000),
                          initialDate: contractEndDate,

                        );
                        if(date!=null){
                          setState(() {
                            contractEndDate=date;
                          });
                        }


                      },
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        caplebal: "",
                        label: "Business Value",
                        hint: "Enter Business Value In Ton",
                        controller: TextEditingController(),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        caplebal: "",
                        label: "Flat Amount",
                        hint: "Enter Amount",
                        controller: TextEditingController(),
                      ),
                    ),
                    SizedBox(width: 20),

                  ],
                ),
                SizedBox(
                  height: 20,

                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonDropDownWidget<String>(
                        hintText: "Payment",
                        items: const [
                          DropdownMenuItem(
                            value: "To be billed",
                            child: Text(
                                "To be billed",
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "To Pay",
                            child: Text("To Pay",style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),),
                          ),
                          DropdownMenuItem(
                            value: "Bill On Date",
                            child: Text("Bill On Date",style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),),
                          ),
                          DropdownMenuItem(child: Text("Paid",style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),), value: "Paid")
                        ],
                        // **********************************************
                        // 3. Update onChanged to use the new select logic
                        // **********************************************
                        onChanged: (val) {
                          selectPaymentTerm(val);
                          if(!selectedPaymentTerms.contains(val)){
                            setState(() {
                              selectedPaymentTerms.add(val!);
                            });
                          }
                        },
                        // We set value to null so it always shows the hint text after selection
                        value: null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CommonDropDownWidget<String>(

                          hintText: "Select Delivery Options",
                          value: selectedDeliveryOptions,
                          items: [
                            DropdownMenuItem(
                                value: "Door Delivery",
                                child: Text("Door Delivery",style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ),
                            ),
                            DropdownMenuItem(
                                value:"Warehouse Delivery",
                                child: Text("WareHouse Delivery",style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                ),)),

                          ], onChanged: (value){
                        setState(() {
                          selectedDeliveryOptions=value;
                          deliverytypecontroller.text = value ?? '';

                        });
                      }),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child: CommonDropDownWidget(
                          hintText: "Enter Mode of Transport",
                          items: [
                            DropdownMenuItem(
                                value:"Air",
                                child: Text("Air")),
                            DropdownMenuItem(value: "Road", child: Text("Road",style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),)),
                            DropdownMenuItem(value:"Rail", child: Text("Rail",style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),))
                          ],
                          onChanged: (value){}),
                    )


                  ],
                ),
                SizedBox(
                  height: 20,

                ),



                Align(
                  alignment: Alignment.centerLeft,

                  child: Wrap(
                    spacing: 8.0, // कार्ड्समध्ये आडवी जागा (Horizontal Spacing)
                    runSpacing: 4.0, // ओळींमध्ये उभी जागा (Vertical Spacing)
                    children: [
                      // ✨ FIX: इथे Spread Operator (...) वापरा!
                      ...selectedPaymentTerms
                          .asMap()
                          .entries
                          .map((entry) => _buildSelectedPaymentTermCard(entry.value, entry.key))
                          .toList(),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 20,
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}