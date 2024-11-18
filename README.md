# Dynamic XML Form Renderer  

This Flutter project dynamically generates and renders custom forms based on XML input. Users can either load predefined XML or input custom XML to create forms with various field types, including text, email, radio buttons, date pickers, and a signature pad.  

## Features  

- **Dynamic Form Rendering**: Parse XML to generate custom forms dynamically.  
- **Supported Field Types**:  
  - Text Input  
  - Email Input  
  - Date Picker  
  - Radio Buttons  
  - Signature Pad  
- **Predefined and Custom XML**: Choose between predefined XML templates or input your own XML.  
- **Form Validation**: Ensures required fields are filled before submission.  

## Code Overview  

### XML Parsing  
The application uses the `xml` package to parse XML strings. Each `<field>` element in the XML defines a form field with attributes like `type`, `name`, `label`, `options`, and `required`.  

### Supported XML Structure  
Below is an example XML structure for defining a form:  

```xml  
<form>  
  <field type="text" name="name" label="Name" required="true" />  
  <field type="email" name="email" label="Email Address" required="true" />  
  <field type="date" name="dob" label="Date of Birth" required="false" />  
  <field type="radio" name="gender" label="Gender" options="Male,Female,Other" required="true" />  
  <field type="drawing" name="signature" label="Signature" required="true" />  
</form>  
```  

### Field Rendering  
Each form field is rendered dynamically based on its `type`:  
- **Text/Email Fields**: Uses `TextFormField` with icons and validation.  
- **Date Picker**: Implements `showDatePicker` for date selection.  
- **Radio Buttons**: Uses `RadioListTile` for multiple-choice options.  
- **Signature Pad**: Integrates the `signature` package for drawing and saving signatures.  

### Key Components  
- **`FormField` Class**: Represents individual form fields.  
- **`parseXML` Method**: Parses XML and creates a list of `FormField` objects.  
- **`_buildField` Method**: Dynamically generates UI widgets for each form field.  
- **`CustomXMLDialog`**: Accepts user-provided XML input.  

### Predefined XML  
The application includes predefined XML templates (`predefinedXML`) for quick testing.  

## How to Use  

1. Clone the repository:  
   ```bash  
   git clone https://github.com/Abhxjith/Custom-XML.git  
   ```  
2. Navigate to the project directory:  
   ```bash  
   cd Custom-XML  
   ```  
3. Install dependencies:  
   ```bash  
   flutter pub get  
   ```  
4. Run the application:  
   ```bash  
   flutter run  
   ```  

## Packages Used  
- `xml`: For parsing XML documents.  
- `intl`: For date formatting.  
- `signature`: For capturing user-drawn signatures.  

## Contributing  
Contributions are welcome! Feel free to open an issue or submit a pull request.  

## License  
This project is licensed under the MIT License.  

---  

### Example Use Case  
1. Select **Predefined XML** or input custom XML.  
2. The form is generated dynamically based on the XML structure.  
3. Fill in the form fields and submit.  
4. View the form data logged to the console upon submission.  

Happy coding! 🚀  
