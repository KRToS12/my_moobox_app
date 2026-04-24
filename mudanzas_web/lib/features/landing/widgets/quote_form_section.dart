import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../core/widgets/hover_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../responsive/breakpoints.dart';

class QuoteFormSection extends StatefulWidget {
  const QuoteFormSection({super.key});

  @override
  State<QuoteFormSection> createState() => _QuoteFormSectionState();
}

class _QuoteFormSectionState extends State<QuoteFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();

  String _moveSize = 'mediano';
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentCoral,
              onPrimary: AppColors.white,
              secondary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF0EE), AppColors.backgroundLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 72 : 112),
      child: ContentWrapper(
        maxWidth: 1100,
        child: AnimatedSection(
          sectionKey: 'quote_form_section',
          child: Column(
            children: [
              Text(
                'COTIZACIÓN GRATIS',
                style: AppTypography.overline,
              ),
              const SizedBox(height: 16),
              Text(
                'Obtén tu precio\nen minutos',
                style: AppTypography.h1Responsive(
                  MediaQuery.of(context).size.width,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Sin compromisos. Respuesta en menos de 24 horas.',
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 40 : 60),

              // Form card
              Container(
                padding: EdgeInsets.all(isMobile ? 24 : 48),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.dividerLight),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: _submitted ? _buildSuccess() : _buildForm(context, isMobile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.statusSuccess.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.statusSuccess,
            size: 44,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '¡Solicitud enviada!',
          style: AppTypography.h2.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Hemos recibido tu solicitud. Nuestro equipo se comunicará contigo en menos de 24 horas con una cotización personalizada.',
          style: AppTypography.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        HoverButton(
          label: 'Enviar otra solicitud',
          variant: HoverButtonVariant.primary,
          icon: Icons.refresh_rounded,
          onPressed: () => setState(() => _submitted = false),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Nombre + Teléfono
          isMobile
              ? Column(
                  children: [
                    _buildField(
                      controller: _nameController,
                      label: 'Nombre completo',
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().length < 8) ? 'Teléfono inválido' : null,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _nameController,
                        label: 'Nombre completo',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildField(
                        controller: _phoneController,
                        label: 'Teléfono',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.trim().length < 8) ? 'Teléfono inválido' : null,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 16),

          // Email
          _buildField(
            controller: _emailController,
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !EmailValidator.validate(v)) ? 'Email inválido' : null,
          ),
          const SizedBox(height: 16),

          // Origen + Destino
          isMobile
              ? Column(
                  children: [
                    _buildField(
                      controller: _originController,
                      label: 'Dirección de origen',
                      icon: Icons.location_on_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa la dirección de origen' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _destinationController,
                      label: 'Dirección de destino',
                      icon: Icons.flag_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa la dirección de destino' : null,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _originController,
                        label: 'Dirección de origen',
                        icon: Icons.location_on_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa la dirección de origen' : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildField(
                        controller: _destinationController,
                        label: 'Dirección de destino',
                        icon: Icons.flag_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Ingresa la dirección de destino' : null,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 16),

          // Tamaño + Fecha
          isMobile
              ? Column(
                  children: [
                    _buildSizeDropdown(),
                    const SizedBox(height: 16),
                    _buildDatePicker(context),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildSizeDropdown()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildDatePicker(context)),
                  ],
                ),
          const SizedBox(height: 16),

          // Notes
          _buildField(
            controller: _notesController,
            label: 'Comentarios adicionales (opcional)',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 32),

          // Submit button
          Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: AppColors.accentCoral,
                      strokeWidth: 3,
                    ),
                  )
                : HoverButton(
                    label: 'Obtener Cotización Gratis',
                    variant: HoverButtonVariant.coral,
                    icon: Icons.send_rounded,
                    width: isMobile ? double.infinity : 340,
                    onPressed: _submit,
                  ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Al enviar, aceptas nuestra política de privacidad. Sin spam, te lo prometemos.',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTypography.body.copyWith(
        color: AppColors.textBlackLight,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentCoral, size: 20),
      ),
    );
  }

  Widget _buildSizeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _moveSize,
      decoration: InputDecoration(
        labelText: 'Tamaño de mudanza',
        prefixIcon: const Icon(
          Icons.open_in_full_rounded,
          color: AppColors.accentCoral,
          size: 20,
        ),
      ),
      style: AppTypography.body.copyWith(
        color: AppColors.textBlackLight,
        fontSize: 15,
      ),
      items: const [
        DropdownMenuItem(value: 'pequeno', child: Text('Pequeño (1-2 ambientes)')),
        DropdownMenuItem(value: 'mediano', child: Text('Mediano (3-4 ambientes)')),
        DropdownMenuItem(value: 'grande', child: Text('Grande (5+ ambientes)')),
        DropdownMenuItem(value: 'comercial', child: Text('Comercial / Oficina')),
      ],
      onChanged: (v) => setState(() => _moveSize = v!),
    );
  }


  Widget _buildDatePicker(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            validator: (_) =>
                _selectedDate == null ? 'Selecciona una fecha' : null,
            style: AppTypography.body.copyWith(
              color: AppColors.textBlackLight,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: _selectedDate == null
                  ? 'Fecha deseada'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              prefixIcon: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.accentCoral,
                size: 20,
              ),
              suffixIcon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.accentCoral,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
