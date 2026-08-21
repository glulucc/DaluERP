namespace DaluERP.Web.Services;

public class EmpresaContext
{
    public long EmpresaId { get; private set; }

    public void EstablecerEmpresa(long empresaId)
    {
        EmpresaId = empresaId;
    }

    public void Limpiar()
    {
        EmpresaId = 0;
    }

    public bool TieneEmpresaSeleccionada =>
        EmpresaId > 0;
}