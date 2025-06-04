
# z to p
fslmaths z_image -ztop p_image
# p to z
fslmaths p_image -ptoz z_image

# t to z: convert t to p, then p to z
ttologp -logpout logp_image ones_image t_image dof
fslmaths logp_image -exp p_image
fslmaths p_image -ptoz z_image


