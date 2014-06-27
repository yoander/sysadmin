# LVM

## Grupos

### Crear
``` 
# vgcreate <volumenes-fisicos|dispositivos>
```

### Reporte
```
# vgs
```

### Listar
``` 
# vgdisplay
```

## PV (Vólumenes Físicos)
    
### Crear
```
# pvcreate <device|partition>
``` 

### Reporte
```
# pvs
```

### Listar
```     
# pvdisplay
```

## LV (Vólumenes Lógicos)

### Crear
```     
# lvcreate -L 30G -n nom-volumen-log nombre-grupo
```

### Listar
```
# lvdisplay
```

### Formatear volumen lógico
```
# mkfs.ext3 -m 0 /dev/nombre-grupo/nom-volumen-log   [-L label]
```

### Montar volumen lógico

Agregar al /etc/fstab

```
/dev/nombre-grupo/nom-volumen-log       /mnt/some-dir             ext3    defaults,acl    1 2 (ACL es opcional)
```

Ó

```
LABEL=label                             /mnt/some-dir              ext3    defaults,acl    1 2 (ACL es opcional)
```
